function __oko_system_collect_security --description 'Collect firewall, AppArmor, Secure Boot, LUKS state under .security'
    set -lx LC_ALL C

    # Firewall: prefer ufw, then firewalld, fall back to nftables presence.
    set -l firewall null
    set -l firewall_active false
    if command -q ufw
        set firewall ufw
        if systemctl is-active --quiet ufw 2>/dev/null
            set firewall_active true
        end
    else if command -q firewall-cmd
        set firewall firewalld
        if systemctl is-active --quiet firewalld 2>/dev/null
            set firewall_active true
        end
    else if command -q nft
        set firewall nftables
        if systemctl is-active --quiet nftables 2>/dev/null
            set firewall_active true
        end
    end

    set -l apparmor false
    if command -q aa-status; and aa-status --enabled 2>/dev/null
        set apparmor true
    end

    set -l secure_boot null
    if command -q bootctl
        set -l sb_line (bootctl status 2>/dev/null | string match -er 'Secure Boot:')
        if test -n "$sb_line"
            set secure_boot (string replace -r '^.*Secure Boot:\s*' '' -- $sb_line | string trim)
        end
    end

    set -l luks_devices_json '[]'
    if command -q lsblk
        # `crypt` (TYPE) is the unlocked mapper device; `crypto_LUKS` (FSTYPE)
        # is the encrypted backing partition. Match either so we catch both
        # the active mapping and the source — useful when one is shown but
        # not the other in `lsblk` listings.
        set -l luks_devs (lsblk -lno NAME,TYPE,FSTYPE 2>/dev/null | awk '$2=="crypt" || $3=="crypto_LUKS" {print $1}')
        if test (count $luks_devs) -gt 0
            set luks_devices_json (printf '%s\n' $luks_devs | jq -R . | jq -s .)
        end
    end

    jq -n \
        --arg firewall "$firewall" \
        --argjson firewall_active "$firewall_active" \
        --argjson apparmor "$apparmor" \
        --arg secure_boot "$secure_boot" \
        --argjson luks "$luks_devices_json" '
        {
            security: {
                firewall: (if $firewall == "null" then null else $firewall end),
                firewall_active: $firewall_active,
                apparmor_enabled: $apparmor,
                secure_boot: (if $secure_boot == "" then null else $secure_boot end),
                luks_devices: $luks
            }
        }'
end
