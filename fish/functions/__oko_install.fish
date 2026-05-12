function __oko_install --description 'Declare installs: update manifest, draft migration, prompt to apply'
    # Usage: __oko_install [--manager M] <pkgs...>
    set -l forced_manager ""
    set -l pkgs
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --manager
                set i (math $i + 1)
                set forced_manager $argv[$i]
            case '--manager=*'
                set forced_manager (string replace -- '--manager=' '' $argv[$i])
            case '*'
                set pkgs $pkgs $argv[$i]
        end
        set i (math $i + 1)
    end

    if test (count $pkgs) -eq 0
        __oko_say nope "Indique o nome do indivíduo a registrar, camarada."
        return 1
    end

    set -l ops_csv ""

    for pkg in $pkgs
        set -l owner (__oko_owner $pkg)
        if test -n "$owner"
            __oko_say ok "$pkg já consta no sistema ($owner). Документ в порядке."
            if not __oko_manifest has $pkg
                __oko_manifest add $pkg $owner
                __oko_say hush "manifest atualizado retroativamente."
            end
            continue
        end

        if __oko_manifest has $pkg
            __oko_say hush "$pkg já está no manifest; pulando."
            continue
        end

        set -l target $forced_manager
        if test -z "$target"
            set target (__oko_resolve $pkg)
        end

        if test -z "$target"
            __oko_stamp rejected "$pkg — nenhum gerenciador o reconhece"
            __oko_say nope "Indivíduo desconhecido. Acesso negado."
            continue
        end

        __oko_manifest add $pkg $target
        __oko_say info "$pkg registrado no manifest via $target."

        if test -z "$ops_csv"
            set ops_csv "$pkg=$target"
        else
            set ops_csv "$ops_csv,$pkg=$target"
        end
    end

    if test -z "$ops_csv"
        __oko_say ok "Nenhuma nova entrada para arquivar. Tudo em ordem."
        return 0
    end

    set -l mig_file (__oko_migration_write install "$ops_csv" "")
    __oko_prompt_apply $mig_file
end
