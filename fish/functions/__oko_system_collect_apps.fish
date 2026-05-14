function __oko_system_collect_apps --description 'Collect curated apps grouped by category under .apps'
    set -l shell_apps starship zoxide fzf eza bat rg fd delta
    set -l editor_apps nvim code hx
    set -l terminal_apps alacritty kitty wezterm ghostty
    set -l dev_apps git gh docker podman distrobox mise python node rustc go
    set -l system_apps paru snapper garuda-update plymouth

    set -l shell_json (__oko_system_apps_group $shell_apps)
    set -l editor_json (__oko_system_apps_group $editor_apps)
    set -l terminal_json (__oko_system_apps_group $terminal_apps)
    set -l dev_json (__oko_system_apps_group $dev_apps)
    set -l system_json (__oko_system_apps_group $system_apps)

    jq -n \
        --argjson shell "$shell_json" \
        --argjson editor "$editor_json" \
        --argjson terminal "$terminal_json" \
        --argjson dev "$dev_json" \
        --argjson system "$system_json" \
        '{apps: {shell: $shell, editor: $editor, terminal: $terminal, dev: $dev, system: $system}}'
end
