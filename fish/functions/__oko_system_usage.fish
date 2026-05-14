function __oko_system_usage --description 'Print oko system usage'
    # Color-or-not detection mirroring the parent dispatcher: usage is
    # often piped through `>&2` on error paths, which makes stdout look
    # non-tty even when stderr is a terminal — fall back to checking
    # stderr before disabling color.
    set -l use_color 1
    if set -q __oko_log_file; or set -q NO_COLOR
        set use_color 0
    else if not isatty stdout; and not isatty stderr
        set use_color 0
    end

    set -l c_title ''
    set -l c_section ''
    set -l c_flag ''
    set -l c_dim ''
    set -l c_reset ''
    if test $use_color -eq 1
        set c_title (set_color --bold cyan)
        set c_section (set_color --bold)
        set c_flag (set_color green)
        set c_dim (set_color brblack)
        set c_reset (set_color normal)
    end

    echo $c_title"oko system"$c_reset" — host snapshot for diagnosis or LLM context"
    echo
    echo $c_section"Usage:"$c_reset
    echo "    "$c_flag"oko system"$c_reset" "$c_dim"[<options>]"$c_reset
    echo "    "$c_flag"oko system"$c_reset"           "$c_dim"[<options>]                  # shorthand"$c_reset
    echo
    echo $c_section"Output formats:"$c_reset
    echo "    "$c_flag"-o, --output"$c_reset" "$c_dim"<fmt>"$c_reset"     json | yaml | csv "$c_dim"(default: terminal pretty-print)"$c_reset
    echo "    "$c_flag"-A, --ai"$c_reset"               LLM-optimized JSON "$c_dim"(forces --output=json)"$c_reset
    echo "    "$c_flag"-S, --no-sudo"$c_reset"          skip the upfront sudo prompt; some fields stay null"
    echo
    echo $c_section"Category filters"$c_reset" "$c_dim"(all default if none specified; combinable)"$c_reset":"
    echo "    "$c_flag"-H, --hardware"$c_reset"         CPU, RAM, GPU, disks, motherboard"
    echo "    "$c_flag"-O, --os"$c_reset"               distro, kernel, libc, systemd, uptime"
    echo "    "$c_flag"-g, --gui"$c_reset"              desktop, session, compositor"
    echo "    "$c_flag"-t, --terminal"$c_reset"         emulator, shell, locale-ish bits"
    echo "    "$c_flag"-a, --apps"$c_reset"             curated set of installed apps + versions"
    echo "        "$c_flag"--storage"$c_reset"          fs, btrfs subvolumes, snapper, swap, zram"
    echo "        "$c_flag"--services"$c_reset"         failed units, slow startup units"
    echo "        "$c_flag"--pkg"$c_reset"              pacman/AUR counts, mirror, helper"
    echo "        "$c_flag"--boot"$c_reset"             loader, kernel cmdline"
    echo "        "$c_flag"--network"$c_reset"          NM state, DNS, hostname, active connection"
    echo "        "$c_flag"--security"$c_reset"         firewall, AppArmor, Secure Boot, LUKS"
    echo "        "$c_flag"--containers"$c_reset"       docker / podman / distrobox"
    echo "        "$c_flag"--locale"$c_reset"           locale, timezone, NTP, keymap"
    echo "        "$c_flag"--theming"$c_reset"          GTK / icon / cursor themes, fonts"
    echo
    echo $c_section"Short flags can be bundled"$c_reset" "$c_dim"(value-taking flags must come last)"$c_reset":"
    echo "    "$c_flag"oko system -aH"$c_reset
    echo "    "$c_flag"oko system -Ao json"$c_reset
    echo "    "$c_flag"oko system -gtO"$c_reset
end
