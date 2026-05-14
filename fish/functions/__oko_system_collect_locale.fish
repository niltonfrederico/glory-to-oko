function __oko_system_collect_locale --description 'Collect locale, timezone, NTP sync, keymap under .locale'
    set -lx LC_ALL C

    set -l system_locale ''
    set -l x11_layout ''
    set -l vc_keymap ''
    if command -q localectl
        set system_locale (localectl status 2>/dev/null | awk -F': +' '/System Locale:/{print $2; exit}')
        set x11_layout (localectl status 2>/dev/null | awk -F': +' '/X11 Layout:/{print $2; exit}')
        set vc_keymap (localectl status 2>/dev/null | awk -F': +' '/VC Keymap:/{print $2; exit}')
    end

    set -l timezone ''
    set -l ntp_sync ''
    if command -q timedatectl
        set timezone (timedatectl show -p Timezone --value 2>/dev/null | string trim)
        set ntp_sync (timedatectl show -p NTPSynchronized --value 2>/dev/null | string trim)
    end

    __oko_json_kv \
        system_locale "$system_locale" \
        x11_layout "$x11_layout" \
        vc_keymap "$vc_keymap" \
        timezone "$timezone" \
        ntp_synchronized "$ntp_sync" \
        | jq '{locale: .}'
end
