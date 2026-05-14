function __oko_system_collect_gui --description 'Collect desktop/session/compositor under .gui'
    set -l desktop "$XDG_CURRENT_DESKTOP"
    set -l session_type "$XDG_SESSION_TYPE"
    set -l desktop_session "$DESKTOP_SESSION"

    set -l compositor ''
    for c in kwin_wayland kwin_x11 gnome-shell Hyprland sway niri river labwc weston Xorg
        if pgrep -x $c >/dev/null 2>&1
            set compositor $c
            break
        end
    end

    __oko_json_kv \
        desktop "$desktop" \
        session_type "$session_type" \
        desktop_session "$desktop_session" \
        compositor "$compositor" \
        | jq '{gui: .}'
end
