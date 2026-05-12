function __oko_remove --description 'Declare removals: update manifest, draft migration, prompt to apply'
    if test (count $argv) -eq 0
        __oko_say nope "Indique o nome do indivíduo a deportar, camarada."
        return 1
    end

    set -l ops_csv ""

    for pkg in $argv
        set -l owner (__oko_owner $pkg)
        set -l manifest_manager ""
        if __oko_manifest has $pkg
            set manifest_manager (__oko_manifest manager-of $pkg)
        end

        if test -z "$owner" -a -z "$manifest_manager"
            __oko_say ok "$pkg não consta no registro. Caso encerrado."
            continue
        end

        # Prefer recorded manifest manager, fall back to detected owner.
        set -l target $manifest_manager
        if test -z "$target"
            set target $owner
        end

        if __oko_manifest has $pkg
            __oko_manifest remove $pkg
            __oko_say info "$pkg removido do manifest (target: $target)."
        else
            __oko_say hush "$pkg ausente do manifest — registrando deportação mesmo assim."
        end

        if test -z "$ops_csv"
            set ops_csv "$pkg=$target"
        else
            set ops_csv "$ops_csv,$pkg=$target"
        end
    end

    if test -z "$ops_csv"
        __oko_say ok "Nada a deportar. Cofre em ordem."
        return 0
    end

    set -l mig_file (__oko_migration_write remove "" "$ops_csv")
    __oko_prompt_apply $mig_file
end
