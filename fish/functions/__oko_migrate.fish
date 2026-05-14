function __oko_migrate --description 'Apply pending migrations, batching ops per manager so deps resolve correctly'
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

        # ---------------- UPGRADE replay (informational only) ----------------
        # Upgrade migrations are an audit trail: versions move forward
        # autonomously and cannot be replayed deterministically. We log
        # the encounter and mark the migration as applied without action.
        set -l n_up (yq '[.operations[] | select(.action == "upgrade") | .managers[].name] | length' $f)
        if test "$n_up" -gt 0
            set -l names (yq -r '.operations[] | select(.action == "upgrade") | .managers[].name' $f | string join ', ')
            __oko_say hush "$id é registro histórico de upgrade ($names) — sem replay."
            __oko_state mark $id
            __oko_stamp approved "$id reconhecida"
            set ran (math $ran + 1)
            continue
        end

        # ---------------- INSTALL replay ----------------
        # Bucket pkgs by manager (resolving missing managers on the fly).
        set -l n_in (yq '[.operations[] | select(.action == "install") | .packages[].name] | length' $f)
        if test "$n_in" -gt 0
            set -l in_managers
            for i in (seq 0 (math $n_in - 1))
                set -l name (yq -r ".operations[] | select(.action == \"install\") | .packages[$i].name" $f)
                set -l manager (yq -r ".operations[] | select(.action == \"install\") | .packages[$i].manager // \"\"" $f)
                if test -z "$name" -o "$name" = null
                    continue
                end
                if __oko_owner $name >/dev/null
                    __oko_say hush "$name já presente, ignorando."
                    continue
                end
                if test -z "$manager" -o "$manager" = null
                    set manager (__oko_resolve $name)
                end
                if test -z "$manager"
                    __oko_say warn "$name não encontrado em nenhum manager. Pulado."
                    continue
                end
                set -l var "__oko_in_$manager"
                set -a $var $name
                if not contains -- $manager $in_managers
                    set in_managers $in_managers $manager
                end
            end

            for m in $in_managers
                set -l var "__oko_in_$m"
                set -l names $$var
                __oko_say info "→ install via $m: $names"
                __oko_do install $m $names
                or __oko_say warn "batch install via $m falhou — rode 'oko check' nos pacotes."
                set -e $var
            end
        end

        # ---------------- REMOVE replay ----------------
        set -l n_rm (yq '[.operations[] | select(.action == "remove") | .packages[].name] | length' $f)
        if test "$n_rm" -gt 0
            set -l rm_managers
            for i in (seq 0 (math $n_rm - 1))
                set -l name (yq -r ".operations[] | select(.action == \"remove\") | .packages[$i].name" $f)
                set -l manager (yq -r ".operations[] | select(.action == \"remove\") | .packages[$i].manager // \"\"" $f)
                if test -z "$name" -o "$name" = null
                    continue
                end
                if test -z "$manager" -o "$manager" = null
                    set manager (__oko_owner $name)
                end
                if test -z "$manager"
                    __oko_say hush "$name não consta no sistema, ignorando."
                    continue
                end
                set -l var "__oko_rm_$manager"
                set -a $var $name
                if not contains -- $manager $rm_managers
                    set rm_managers $rm_managers $manager
                end
            end

            for m in $rm_managers
                set -l var "__oko_rm_$m"
                set -l names $$var
                __oko_say info "→ remove via $m: $names"
                __oko_do remove $m $names
                or __oko_say warn "batch remove via $m falhou — verifique dependências e rode novamente."
                set -e $var
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
