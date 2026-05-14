function __oko_upgrade --description 'Upgrade managed package managers in priority order; archive audit migration'
    set -l forced_manager ""
    set -l dry_run 0
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --manager
                set i (math $i + 1)
                set forced_manager $argv[$i]
            case '--manager=*'
                set forced_manager (string replace -- '--manager=' '' $argv[$i])
            case --dry-run -n
                set dry_run 1
            case -h --help
                __oko_upgrade_help
                return 0
            case '*'
                __oko_say nope "Argumento desconhecido: $argv[$i]"
                __oko_upgrade_help
                return 1
        end
        set i (math $i + 1)
    end

    set -l targets (__oko_config managers)
    if test -n "$forced_manager"
        if not __oko_config has $forced_manager
            __oko_say nope "Manager $forced_manager não consta em ~/.oko/config.yaml."
            return 1
        end
        set targets $forced_manager
    end

    set -l ran_csv ""
    set -l any_failed 0

    for m in $targets
        set -l cmd (__oko_config command $m)
        if not command -q $cmd
            __oko_say hush "$m ($cmd) não está disponível neste host — pulando."
            continue
        end

        set -l args (__oko_config args $m)
        set -l use_sudo 0
        if __oko_config sudoer $m
            set use_sudo 1
        end

        __oko_say info "→ atualizando via $m..."

        if test $dry_run -eq 1
            __oko_upgrade_show $use_sudo $m $cmd $args
            continue
        end

        __oko_upgrade_run $use_sudo $m $cmd $args
        set -l rc $status
        set -l ok true
        if test $rc -ne 0
            set ok false
            set any_failed 1
            __oko_say warn "$m falhou (exit $rc)."
        end

        set -l count (__oko_upgrade_count $m)

        if test -z "$ran_csv"
            set ran_csv "$m:$ok:$count"
        else
            set ran_csv "$ran_csv,$m:$ok:$count"
        end
    end

    if test $dry_run -eq 1
        __oko_say hush "Dry-run: nada executado, nenhum carimbo emitido."
        return 0
    end

    if test -z "$ran_csv"
        __oko_say ok "Nenhum manager elegível. Cofre em ordem."
        return 0
    end

    set -l mig_file (__oko_migration_write_upgrade "$ran_csv")
    set -l mig_id (basename $mig_file .yaml)
    __oko_state mark $mig_id

    if test $any_failed -eq 1
        __oko_stamp rejected "$mig_id — um ou mais managers falharam"
        return 1
    else
        __oko_stamp approved "$mig_id arquivada e aplicada"
        return 0
    end
end

function __oko_upgrade_run --description 'Run the canonical upgrade command for one manager'
    set -l use_sudo $argv[1]
    set -l manager $argv[2]
    set -l cmd $argv[3]
    set -l args $argv[4..]

    switch $manager
        case brew
            __oko_do_run $use_sudo $cmd $args update
            and __oko_do_run $use_sudo $cmd $args upgrade
        case uvx
            __oko_do_run $use_sudo $cmd $args tool upgrade --all
        case pipx
            __oko_do_run $use_sudo $cmd $args upgrade-all
        case npm
            __oko_do_run $use_sudo $cmd $args update -g
        case paru
            __oko_do_run $use_sudo $cmd $args -Syu --noconfirm
        case snap
            __oko_do_run $use_sudo $cmd $args refresh
        case '*'
            __oko_say warn "Sem receita de upgrade para $manager — pulando."
            return 1
    end
end

function __oko_upgrade_show --description 'Print the canonical upgrade command for one manager (dry-run)'
    set -l use_sudo $argv[1]
    set -l manager $argv[2]
    set -l cmd $argv[3]
    set -l args $argv[4..]

    set -l prefix ""
    if test "$use_sudo" = 1
        set prefix "sudo "
    end

    switch $manager
        case brew
            echo "  $prefix$cmd $args update && $prefix$cmd $args upgrade"
        case uvx
            echo "  $prefix$cmd $args tool upgrade --all"
        case pipx
            echo "  $prefix$cmd $args upgrade-all"
        case npm
            echo "  $prefix$cmd $args update -g"
        case paru
            echo "  $prefix$cmd $args -Syu --noconfirm"
        case snap
            echo "  $prefix$cmd $args refresh"
        case '*'
            echo "  (sem receita)"
    end
end

function __oko_upgrade_count --description 'Best-effort count of managed packages for audit'
    set -l manager $argv[1]
    set -l n 0
    switch $manager
        case brew
            if command -q brew
                set n (math (brew list --formula -1 2>/dev/null | wc -l) + (brew list --cask -1 2>/dev/null | wc -l))
            end
        case uvx
            command -q uv; and set n (uv tool list 2>/dev/null | awk '/^[^ ]/' | wc -l)
        case pipx
            command -q pipx; and set n (pipx list --short 2>/dev/null | wc -l)
        case npm
            command -q npm; and set n (npm ls -g --depth=0 --parseable 2>/dev/null | tail -n +2 | wc -l)
        case paru
            command -q pacman; and set n (pacman -Qq 2>/dev/null | wc -l)
        case snap
            command -q snap; and set n (snap list 2>/dev/null | tail -n +2 | wc -l)
    end
    echo (string trim -- $n)
end

function __oko_upgrade_help
    set -l y (set_color yellow)
    set -l d (set_color brblack)
    set -l r (set_color normal)
    echo
    echo "  $y""oko upgrade$r — atualizar todos os managers declarados em ~/.oko/config.yaml"
    echo
    echo "    $y--manager $r<id>$d   restringe a um único manager$r"
    echo "    $y-n, --dry-run$r       mostra os comandos sem executar; não arquiva migration$r"
    echo "    $y-h, --help$r          esta ajuda"
    echo
    echo "  $d""Execução real redige uma migration audit-only (action: upgrade) e marca aplicada.$r"
    echo "  $d""--detailed (versões pré/pós por pacote) está planejado mas ainda não implementado.$r"
    echo
end
