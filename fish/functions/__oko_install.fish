function __oko_install --description 'Install packages, respecting manager priority'
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

    for pkg in $pkgs
        set -l owner (__oko_owner $pkg)
        if test -n "$owner"
            __oko_say ok "$pkg já consta no registro ($owner). Документ в порядке."
            if not __oko_manifest has $pkg
                __oko_manifest add $pkg $owner
                __oko_say hush "manifest atualizado retroativamente."
            end
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

        __oko_say info "Processando $pkg via $target..."
        if __oko_do install $target $pkg
            __oko_manifest add $pkg $target
            __oko_stamp approved "$pkg via $target"
            __oko_say ok "Спасибо. Bem-vindo a Arstotzka, $pkg."
        else
            __oko_stamp rejected "$pkg falhou na fronteira ($target)"
            __oko_say warn "Documento rejeitado pelo gerenciador. Verifique manualmente."
        end
    end
end
