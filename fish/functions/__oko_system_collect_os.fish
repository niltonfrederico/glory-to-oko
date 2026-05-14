function __oko_system_collect_os --description 'Collect distro/kernel/init/uptime under .os'
    set -lx LC_ALL C

    set -l distro ''
    set -l distro_id ''
    if test -r /etc/os-release
        set distro (string match -r '^PRETTY_NAME="?(.+?)"?$' </etc/os-release | tail -1)
        set distro_id (string match -r '^ID=(.+)$' </etc/os-release | tail -1)
    end

    set -l kernel (uname -r)
    set -l arch (uname -m)
    set -l host (uname -n)

    set -l libc ''
    set libc (ldd --version 2>/dev/null | head -n1)

    set -l systemd_version ''
    if command -q systemctl
        set systemd_version (systemctl --version 2>/dev/null | head -n1)
    end

    set -l uptime_pretty ''
    set uptime_pretty (uptime -p 2>/dev/null | string trim)

    __oko_json_kv \
        distro "$distro" \
        distro_id "$distro_id" \
        kernel "$kernel" \
        arch "$arch" \
        hostname "$host" \
        libc "$libc" \
        systemd_version "$systemd_version" \
        uptime "$uptime_pretty" \
        | jq '{os: .}'
end
