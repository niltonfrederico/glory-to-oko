function __oko_system_apps_group --description 'Build a {bin: version|null} JSON object from a list of binary names'
    set -l args
    set -l parts
    set -l idx 1
    for app in $argv
        set -l ver ''
        if command -q $app
            set ver (command $app --version 2>/dev/null | head -n1 | string trim)
            test -z "$ver"; and set ver installed
        end
        set -a args --arg n$idx $app --arg v$idx "$ver"
        set -a parts "(\$n$idx): (if \$v$idx == \"\" then null else \$v$idx end)"
        set idx (math $idx + 1)
    end

    if test (count $parts) -eq 0
        echo '{}'
        return 0
    end

    set -l filter '{'(string join ', ' -- $parts)'}'
    jq -n $args $filter
end
