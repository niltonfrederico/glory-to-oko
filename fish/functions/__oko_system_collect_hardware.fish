function __oko_system_collect_hardware --description 'Collect CPU, RAM, GPU, disks, motherboard under .hardware'
    # lscpu/lsblk respect $LANG — pin to C so our awk patterns match English field names.
    set -lx LC_ALL C

    set -l cpu_model (lscpu 2>/dev/null | awk -F': +' '/^Model name:/{print $2; exit}')
    set -l cpu_sockets (lscpu 2>/dev/null | awk -F': +' '/^Socket\(s\):/{print $2; exit}')
    set -l cpu_cores (lscpu 2>/dev/null | awk -F': +' '/^Core\(s\) per socket:/{print $2; exit}')
    set -l cpu_threads (lscpu 2>/dev/null | awk -F': +' '/^Thread\(s\) per core:/{print $2; exit}')
    set -l cpu_max_mhz (lscpu 2>/dev/null | awk -F': +' '/^CPU max MHz:/{print $2; exit}')

    set -l ram_total_bytes (awk '/^MemTotal:/{print $2*1024; exit}' /proc/meminfo 2>/dev/null)
    set -l ram_available_bytes (awk '/^MemAvailable:/{print $2*1024; exit}' /proc/meminfo 2>/dev/null)

    set -l gpu_lines (lspci 2>/dev/null | grep -iE 'vga|3d|display' | string trim)
    set -l gpus_json '[]'
    if test (count $gpu_lines) -gt 0
        set gpus_json (printf '%s\n' $gpu_lines | jq -R . | jq -s .)
    end

    set -l disks_json '[]'
    # --bytes forces numeric SIZE; without it Garuda's pt-BR locale prints "91,7M".
    set -l disks_raw (lsblk -d -o NAME,SIZE,MODEL,ROTA --bytes --json 2>/dev/null)
    if test -n "$disks_raw"
        set disks_json (echo $disks_raw | jq '[.blockdevices[]? | select(.name | test("^loop|^zram|^sr") | not)]')
    end

    set -l board_vendor ''
    set -l board_name ''
    test -r /sys/class/dmi/id/board_vendor; and set board_vendor (string trim <"/sys/class/dmi/id/board_vendor")
    test -r /sys/class/dmi/id/board_name; and set board_name (string trim <"/sys/class/dmi/id/board_name")

    jq -n \
        --arg cpu_model "$cpu_model" \
        --arg cpu_sockets "$cpu_sockets" \
        --arg cpu_cores "$cpu_cores" \
        --arg cpu_threads "$cpu_threads" \
        --arg cpu_max_mhz "$cpu_max_mhz" \
        --arg ram_total "$ram_total_bytes" \
        --arg ram_available "$ram_available_bytes" \
        --argjson gpus "$gpus_json" \
        --argjson disks "$disks_json" \
        --arg board_vendor "$board_vendor" \
        --arg board_name "$board_name" '
        def s2null: if . == "" then null else . end;
        {
            hardware: {
                cpu: {
                    model: $cpu_model | s2null,
                    sockets: $cpu_sockets | s2null,
                    cores_per_socket: $cpu_cores | s2null,
                    threads_per_core: $cpu_threads | s2null,
                    max_mhz: $cpu_max_mhz | s2null
                },
                ram_bytes: {
                    total: $ram_total | s2null,
                    available: $ram_available | s2null
                },
                gpus: $gpus,
                disks: $disks,
                motherboard: {
                    vendor: $board_vendor | s2null,
                    name: $board_name | s2null
                }
            }
        }'
end
