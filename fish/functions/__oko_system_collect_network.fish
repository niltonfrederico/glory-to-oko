function __oko_system_collect_network --description 'Collect NetworkManager state, active connection, DNS, hostname under .network'
    set -l host (uname -n)

    set -l nm_state ''
    set -l active_json '[]'
    if command -q nmcli
        set nm_state (nmcli -t -f STATE general 2>/dev/null | head -n1)

        # Each line: NAME:TYPE:DEVICE — parse into objects.
        set -l active_lines (nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>/dev/null)
        if test (count $active_lines) -gt 0
            set active_json (printf '%s\n' $active_lines | jq -R 'split(":") | {name: .[0], type: .[1], device: .[2]}' | jq -s .)
        end
    end

    set -l dns_json '[]'
    set -l dns_lines
    if command -q resolvectl; and resolvectl status >/dev/null 2>&1
        # `resolvectl dns` lists per-link DNS; flatten unique addresses.
        set dns_lines (resolvectl dns 2>/dev/null | awk -F': ' 'NF>1 {gsub(/^ +/,"",$2); if ($2!="") print $2}' | tr ' ' '\n' | string match -er '.+' | sort -u)
    end
    # If systemd-resolved isn't running, fall back to the classic resolv.conf.
    if test (count $dns_lines) -eq 0; and test -r /etc/resolv.conf
        set dns_lines (awk '$1=="nameserver" && $2!="" {print $2}' /etc/resolv.conf | sort -u)
    end
    if test (count $dns_lines) -gt 0
        set dns_json (printf '%s\n' $dns_lines | jq -R . | jq -s .)
    end

    jq -n \
        --arg host "$host" \
        --arg nm_state "$nm_state" \
        --argjson active "$active_json" \
        --argjson dns "$dns_json" '
        {
            network: {
                hostname: $host,
                nm_state: (if $nm_state == "" then null else $nm_state end),
                active_connections: $active,
                dns_servers: $dns
            }
        }'
end
