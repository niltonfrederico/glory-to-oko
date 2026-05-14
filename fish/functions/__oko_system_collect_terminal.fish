function __oko_system_collect_terminal --description 'Collect $TERM, emulator, shell, version under .terminal'
    set -l term_var "$TERM"
    set -l term_program "$TERM_PROGRAM"
    set -l colorterm "$COLORTERM"
    set -l shell_path "$SHELL"
    set -l fish_ver (fish --version 2>/dev/null)

    # Walk parents from current fish until a non-shell process is found —
    # that's the terminal emulator. /proc/.../comm holds the executable
    # name; PPid lives in /proc/.../status.
    set -l emulator ''
    set -l pid $fish_pid
    for _i in (seq 1 8)
        test -r /proc/$pid/status; or break
        set -l ppid (awk '/^PPid:/{print $2; exit}' /proc/$pid/status)
        test -z "$ppid" -o "$ppid" = 0; and break
        test -r /proc/$ppid/comm; or break
        set -l comm (string trim <"/proc/$ppid/comm")
        switch $comm
            case fish bash zsh sh dash ksh
                set pid $ppid
                continue
            case '*'
                set emulator $comm
                break
        end
    end

    __oko_json_kv \
        term "$term_var" \
        term_program "$term_program" \
        colorterm "$colorterm" \
        emulator "$emulator" \
        shell "$shell_path" \
        fish_version "$fish_ver" \
        | jq '{terminal: .}'
end
