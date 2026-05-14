function __oko_system --description 'Snapshot of host: hardware, OS, GUI, terminal, packages, services, storage, network, security, containers, locale, theming, and important apps'
    # All 14 categories are individual boolean flags. Five common ones get
    # short forms; the rest are longform-only to avoid letter collisions.
    # `o/output=` takes a value, so it must end any short-flag bundle
    # (`-Ao json`, never `-oA json`). `A/ai` overrides `--output` to json.
    argparse \
        h/help \
        A/ai \
        S/no-sudo \
        'o/output=' \
        H/hardware O/os g/gui t/terminal a/apps \
        storage services pkg boot network security containers locale theming \
        -- $argv
    or return

    # Defensive cleanup: if a prior run was interrupted between sudo grant
    # and the trailing `set -e`, the global var could leak into this run.
    # Clear here so the sudo path below is the single source of truth.
    set -e __oko_system_sudo

    if set -q _flag_help
        __oko_system_usage
        return 0
    end

    set -l all_categories hardware os gui terminal apps storage services pkg boot network security containers locale theming

    set -l selected
    for cat in $all_categories
        set -l flag _flag_$cat
        if set -q $flag
            set -a selected $cat
        end
    end
    if test (count $selected) -eq 0
        set selected $all_categories
    end

    set -l output_format
    if set -q _flag_output
        set output_format $_flag_output
    end

    if set -q _flag_ai
        set output_format json
    end

    if test -n "$output_format"
        switch $output_format
            case json yaml csv
            case '*'
                __oko_log error info.system "--output must be one of: json, yaml, csv (got: **$output_format**)"
                return 2
        end
    end

    # Sudo cache priming. We run `sudo -v` upfront with a visible
    # announcement so collectors can later use `sudo -n <cmd>` without
    # blocking. Only the few collectors that genuinely benefit (storage:
    # snapper snapshot counts) will reach for it; the rest stay user-context.
    if not set -q _flag_no_sudo; and command -q sudo; and isatty stderr; and not set -q __oko_log_file
        __oko_log info info.system "priming sudo (snapper snapshot counts) — pass **--no-sudo** to skip"
        if sudo -v
            set -gx __oko_system_sudo 1
        else
            __oko_log warn info.system "continuing without sudo"
        end
    end

    set -l show_spinner 0
    if isatty stderr; and not set -q __oko_log_file
        set show_spinner 1
    end

    if test $show_spinner -eq 1
        __oko_spinner_start "gathering system info"
    end

    set -l fragments
    for cat in $selected
        set -l fn __oko_system_collect_$cat
        if not functions -q $fn
            __oko_log warn info.system "collector **$fn** missing, skipping"
            continue
        end
        set -l frag ($fn)
        if test (count $frag) -gt 0
            set -a fragments (string join \n -- $frag)
        end
    end

    if test $show_spinner -eq 1
        __oko_spinner_stop
    end

    if test (count $fragments) -eq 0
        echo '{}' | __oko_system_dispatch_format $output_format
        set -e __oko_system_sudo
        return 0
    end

    # Each fragment is a JSON object with a single top-level key (the
    # category). `jq -s 'add'` merges N such objects into one — equivalent
    # to `dict(**a, **b, **c)` in Python. Slurp via stdin keeps the call
    # site free of temp files.
    string join \n -- $fragments | jq -s add | __oko_system_dispatch_format $output_format
    set -l rc $status
    set -e __oko_system_sudo
    return $rc
end
