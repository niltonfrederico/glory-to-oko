function __oko_system_collect_services --description 'Collect failed units, slowest startup units, boot total under .services'
    set -lx LC_ALL C

    set -l failed_json '[]'
    if command -q systemctl
        set -l failed (systemctl --failed --no-legend --plain --no-pager 2>/dev/null | awk 'NF>0 {print $1}')
        if test (count $failed) -gt 0
            set failed_json (printf '%s\n' $failed | jq -R . | jq -s .)
        end
    end

    set -l blame_json '[]'
    set -l boot_total ''
    if command -q systemd-analyze
        # Pre-split "TIME UNIT" with awk into TAB-separated columns so jq
        # only has to do `split("\t")` — avoids escaping PCRE escapes
        # through fish single quotes and JSON unescape twice.
        set -l blame_tsv (systemd-analyze blame --no-pager 2>/dev/null | head -n 10 | awk 'NF>=2 {time=$1; $1=""; sub(/^ +/,""); print time"\t"$0}')
        if test (count $blame_tsv) -gt 0
            set blame_json (printf '%s\n' $blame_tsv | jq -R 'split("\t") | {time: .[0], unit: .[1]}' | jq -s .)
        end
        set boot_total (systemd-analyze 2>/dev/null | head -n1 | string trim)
    end

    jq -n \
        --argjson failed "$failed_json" \
        --argjson blame "$blame_json" \
        --arg boot_total "$boot_total" '
        {
            services: {
                failed_units: $failed,
                slowest_units: $blame,
                boot_total: (if $boot_total == "" then null else $boot_total end)
            }
        }'
end
