function __oko_system_collect_pkg --description 'Collect pacman/AUR counts, helper, mirror, last sync under .pkg'
    set -l total_count ''
    set -l explicit_count ''
    set -l foreign_count ''
    if command -q pacman
        set total_count (pacman -Q 2>/dev/null | wc -l | string trim)
        set explicit_count (pacman -Qe 2>/dev/null | wc -l | string trim)
        set foreign_count (pacman -Qm 2>/dev/null | wc -l | string trim)
    end

    set -l aur_helper ''
    set -l aur_helper_version ''
    if command -q paru
        set aur_helper paru
        set aur_helper_version (paru --version 2>/dev/null | head -n1 | string trim)
    end

    set -l chaotic_aur false
    if test -r /etc/pacman.conf; and grep -q '^\[chaotic-aur\]' /etc/pacman.conf
        set chaotic_aur true
    end

    set -l last_sync ''
    if test -r /var/lib/pacman/sync/core.db
        set -l ts (stat -c %Y /var/lib/pacman/sync/core.db 2>/dev/null)
        if test -n "$ts"
            set last_sync (date -u -d @$ts +%FT%TZ)
        end
    end

    jq -n \
        --arg total "$total_count" \
        --arg explicit "$explicit_count" \
        --arg foreign "$foreign_count" \
        --arg helper "$aur_helper" \
        --arg helper_version "$aur_helper_version" \
        --argjson chaotic "$chaotic_aur" \
        --arg last_sync "$last_sync" '
        def s2null: if . == "" then null else . end;
        {
            pkg: {
                total: $total | s2null,
                explicit: $explicit | s2null,
                foreign: $foreign | s2null,
                aur_helper: $helper | s2null,
                aur_helper_version: $helper_version | s2null,
                chaotic_aur_enabled: $chaotic,
                last_db_sync: $last_sync | s2null
            }
        }'
end
