function __oko_system_containers_runtime --description 'Build {present, version, running} JSON for a container runtime'
    set -l bin $argv[1]
    set -l version_cmd $argv[2]
    set -l ps_cmd $argv[3]

    if not command -q $bin
        echo '{"present": false, "version": null, "running": null}'
        return 0
    end

    set -l ver (eval $version_cmd 2>/dev/null | head -n1 | string trim)
    set -l count (eval $ps_cmd 2>/dev/null | wc -l | string trim)

    jq -n --arg v "$ver" --arg c "$count" '
        {
            present: true,
            version: (if $v == "" then null else $v end),
            running: ($c | tonumber? // null)
        }'
end
