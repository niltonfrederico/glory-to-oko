function __oko_config --description 'Read package-manager config from ~/.oko/config.yaml'
    set -l action $argv[1]
    set -l file (__oko_config_path)

    if not test -f $file
        __oko_config_init
    end

    switch $action
        case managers
            # Priority ascending, ties broken by identifier ascending for determinism.
            yq -r '.package_managers | to_entries | sort_by([.value.priority, .key]) | .[].key' $file
        case command
            set -l m $argv[2]
            set -l v (yq -r ".package_managers[\"$m\"].command // \"\"" $file)
            if test -z "$v" -o "$v" = null
                echo $m
            else
                echo $v
            end
        case args
            set -l m $argv[2]
            # Emit one arg per line so callers can `read -a` or capture with (cmd).
            yq -r ".package_managers[\"$m\"].args // [] | .[]" $file
        case sudoer
            set -l m $argv[2]
            test (yq -r ".package_managers[\"$m\"].sudoer // false" $file) = true
        case has
            set -l m $argv[2]
            set -l found (yq -r ".package_managers | has(\"$m\")" $file)
            test "$found" = true
        case '*'
            __oko_say nope "config: ação desconhecida $action"
            return 1
    end
end
