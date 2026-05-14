function __oko_system_collect_storage --description 'Collect root fs, btrfs subvolumes, snapper configs, swap, zram under .storage'
    set -l root_fs ''
    if command -q findmnt
        set root_fs (findmnt -no FSTYPE / 2>/dev/null)
    end

    set -l subvols_json '[]'
    if test "$root_fs" = btrfs; and command -q findmnt
        # `btrfs subvolume list /` needs root. `findmnt` reads /proc/self/mountinfo
        # which is world-readable — same data (mounted subvolumes), no sudo.
        # Each row: {mountpoint, subvol} extracted from the `subvol=` mount option.
        set -l rows (findmnt -t btrfs -nlo TARGET,OPTIONS 2>/dev/null | awk '
            {
                target = $1
                $1 = ""; sub(/^ +/, "")
                # extract subvol=/path from comma-separated mount options
                n = split($0, opts, ",")
                subvol = ""
                for (i = 1; i <= n; i++) if (opts[i] ~ /^subvol=/) { sub(/^subvol=/, "", opts[i]); subvol = opts[i] }
                if (subvol != "") print target "\t" subvol
            }')
        if test (count $rows) -gt 0
            set subvols_json (printf '%s\n' $rows | jq -R 'split("\t") | {mountpoint: .[0], subvol: .[1]}' | jq -s .)
        end
    end

    set -l snapper_configs_json '[]'
    set -l snapper_names
    if command -q snapper
        # `snapper list-configs` prints a header (2 lines) then `Config | Subvolume`.
        set snapper_names (snapper list-configs 2>/dev/null | awk 'NR>2 && NF>0 {print $1}')
        if test (count $snapper_names) -gt 0
            set snapper_configs_json (printf '%s\n' $snapper_names | jq -R . | jq -s .)
        end
    end

    # Snapshot counts per snapper config — `snapper -c <cfg> list` requires
    # root. We rely on the entrypoint having primed the sudo cache via
    # `sudo -v`; here we use `sudo -n` so a stale cache fails fast instead
    # of blocking. Without sudo, the field stays null.
    set -l snapshots_json null
    if set -q __oko_system_sudo; and command -q snapper; and test (count $snapper_names) -gt 0
        set -l args
        set -l parts
        set -l idx 1
        for cfg in $snapper_names
            # `snapper list -t single` has 2 header lines (column titles +
            # separator); rest is one snapshot per row. Empty body → 0.
            set -l count (sudo -n snapper -c $cfg list -t single 2>/dev/null | awk 'NR>2 && NF>0' | wc -l | string trim)
            test -z "$count"; and set count 0
            set -a args --arg n$idx $cfg --argjson c$idx "$count"
            set -a parts "(\$n$idx): \$c$idx"
            set idx (math $idx + 1)
        end
        if test (count $parts) -gt 0
            set snapshots_json (jq -n $args '{'(string join ', ' -- $parts)'}')
        end
    end

    set -l swap_json '[]'
    set -l swap_raw (swapon --show=NAME,TYPE,SIZE,USED --bytes --json 2>/dev/null)
    if test -n "$swap_raw"
        set swap_json (echo $swap_raw | jq '.swap // []')
    end

    set -l zram_present false
    for d in /sys/block/zram*
        if path is -d $d
            set zram_present true
            break
        end
    end

    jq -n \
        --arg root_fs "$root_fs" \
        --argjson subvols "$subvols_json" \
        --argjson snapper_configs "$snapper_configs_json" \
        --argjson snapper_snapshots "$snapshots_json" \
        --argjson swap "$swap_json" \
        --argjson zram "$zram_present" '
        {
            storage: {
                root_fs: (if $root_fs == "" then null else $root_fs end),
                btrfs_subvolumes: $subvols,
                snapper_configs: $snapper_configs,
                snapper_snapshots: $snapper_snapshots,
                swap: $swap,
                zram_present: $zram
            }
        }'
end
