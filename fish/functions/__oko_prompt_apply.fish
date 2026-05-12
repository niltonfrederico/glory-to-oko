function __oko_prompt_apply --description 'Prompt to apply a freshly drafted migration; discard on rejection'
    # Usage: __oko_prompt_apply <migration_file>
    set -l mig_file $argv[1]
    set -l slug (basename $mig_file .yaml)

    __oko_say info "Migration redigida: $slug"
    __oko_say hush "$mig_file"

    read -P '  Aplicar agora? [Y/n] ' answer
    set answer (string lower (string trim $answer))

    if test -z "$answer" -o "$answer" = y -o "$answer" = yes -o "$answer" = s -o "$answer" = sim
        __oko_migrate
        return $status
    end

    rm -f $mig_file
    __oko_say hush "Migration descartada. Manifest mantido — refaça com 'oko makemigrations' se mudar de ideia."
end
