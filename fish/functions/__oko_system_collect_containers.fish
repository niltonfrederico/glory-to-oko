function __oko_system_collect_containers --description 'Collect docker/podman/distrobox presence and running counts under .containers'
    set -l docker_json (__oko_system_containers_runtime docker 'docker --version' 'docker ps -q')
    set -l podman_json (__oko_system_containers_runtime podman 'podman --version' 'podman ps -q')

    # distrobox uses `distrobox list` which prints a header line; subtract 1.
    set -l distrobox_json '{"present": false, "version": null, "running": null}'
    if command -q distrobox
        set -l ver (distrobox --version 2>/dev/null | head -n1 | string trim)
        set -l count (distrobox list 2>/dev/null | tail -n +2 | awk 'NF>0' | wc -l | string trim)
        set distrobox_json (jq -n --arg v "$ver" --arg c "$count" '{present: true, version: (if $v == "" then null else $v end), running: ($c | tonumber? // null)}')
    end

    jq -n \
        --argjson docker "$docker_json" \
        --argjson podman "$podman_json" \
        --argjson distrobox "$distrobox_json" \
        '{containers: {docker: $docker, podman: $podman, distrobox: $distrobox}}'
end
