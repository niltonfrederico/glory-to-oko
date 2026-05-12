function __oko_remove --description 'Remove packages, silently skipping unknown ones'
    if test (count $argv) -eq 0
        __oko_say nope "Indique o nome do indivíduo a deportar, camarada."
        return 1
    end

    for pkg in $argv
        set -l owner (__oko_owner $pkg)
        if test -z "$owner"
            __oko_say ok "$pkg não consta no registro. Caso encerrado."
            if __oko_manifest has $pkg
                __oko_manifest remove $pkg
                __oko_say hush "manifest depurado (entrada órfã removida)."
            end
            continue
        end

        __oko_say info "Deportando $pkg via $owner..."
        if __oko_do remove $owner $pkg
            __oko_manifest remove $pkg
            __oko_stamp approved "$pkg removido via $owner"
            __oko_say ok "Прощай, $pkg. Carimbo final aplicado."
        else
            __oko_stamp rejected "$pkg resistiu à deportação ($owner)"
            __oko_say warn "Gerenciador recusou. Verifique dependências."
        end
    end
end
