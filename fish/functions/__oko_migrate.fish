function __oko_migrate --description 'Apply pending migrations, silently skipping conflicts'
    set -l mig_dir (__oko_paths migrations)
    set -l files $mig_dir/*.yaml
    if not test -e $files[1] 2>/dev/null
        __oko_say ok "Nenhuma migration arquivada. Cofre vazio, camarada."
        return 0
    end

    set -l applied_ids (__oko_state applied)
    set -l ran 0

    for f in $files
        set -l id (yq -r '.id' $f)
        if contains -- $id $applied_ids
            __oko_say hush "$id já carimbada, pulando."
            continue
        end

        __oko_say info "Aplicando $id..."
        # Replay install ops
        set -l n_pkgs (yq '[.operations[] | select(.action == "install") | .packages[].name] | length' $f)
        if test "$n_pkgs" -gt 0
            for i in (seq 0 (math $n_pkgs - 1))
                set -l name (yq -r ".operations[] | select(.action == \"install\") | .packages[$i].name" $f)
                set -l manager (yq -r ".operations[] | select(.action == \"install\") | .packages[$i].manager // \"\"" $f)
                if test -z "$name" -o "$name" = "null"
                    continue
                end
                if __oko_owner $name >/dev/null
                    __oko_say hush "$name já presente, ignorando."
                    continue
                end
                if test -z "$manager" -o "$manager" = "null"
                    set manager (__oko_resolve $name)
                end
                if test -z "$manager"
                    __oko_say warn "$name não encontrado em nenhum manager. Pulado."
                    continue
                end
                __oko_say info "→ install $name via $manager"
                __oko_do install $manager $name
                or __oko_say warn "$name falhou silenciosamente."
            end
        end

        # Replay remove ops
        set -l n_rm (yq '[.operations[] | select(.action == "remove") | .packages[].name] | length' $f)
        if test "$n_rm" -gt 0
            for i in (seq 0 (math $n_rm - 1))
                set -l name (yq -r ".operations[] | select(.action == \"remove\") | .packages[$i].name" $f)
                if test -z "$name" -o "$name" = "null"
                    continue
                end
                set -l owner (__oko_owner $name)
                if test -z "$owner"
                    __oko_say hush "$name não consta, ignorando."
                    continue
                end
                __oko_say info "→ remove $name via $owner"
                __oko_do remove $owner $name
                or __oko_say warn "$name resistiu silenciosamente."
            end
        end

        __oko_state mark $id
        __oko_stamp approved "$id aplicada"
        set ran (math $ran + 1)
    end

    if test $ran -eq 0
        __oko_say ok "Nenhuma operação pendente. Cofre em ordem."
    else
        __oko_say ok "$ran migration(s) aplicada(s). Слава ОТДЕЛУ."
    end
end
