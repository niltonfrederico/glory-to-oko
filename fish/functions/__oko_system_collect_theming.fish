function __oko_system_collect_theming --description 'Collect GTK/icon/cursor themes and font count under .theming'
    set -l gtk_theme ''
    set -l icon_theme ''
    set -l cursor_theme ''
    if command -q gsettings
        set gtk_theme (gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | string trim --chars=\'\")
        set icon_theme (gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | string trim --chars=\'\")
        set cursor_theme (gsettings get org.gnome.desktop.interface cursor-theme 2>/dev/null | string trim --chars=\'\")
    end

    set -l font_count ''
    if command -q fc-list
        set font_count (fc-list 2>/dev/null | wc -l | string trim)
    end

    __oko_json_kv \
        gtk_theme "$gtk_theme" \
        icon_theme "$icon_theme" \
        cursor_theme "$cursor_theme" \
        font_count "$font_count" \
        | jq '{theming: .}'
end
