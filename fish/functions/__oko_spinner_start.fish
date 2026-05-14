function __oko_spinner_start --description 'Start animated dots spinner on stderr'
    set -l label "$argv[1]"

    if not isatty stderr; or set -q __oko_log_file
        return 0
    end

    if set -q __oko_spinner_pid
        __oko_spinner_stop
    end

    # Backgrounded subshell cycles through `.`, `..`, `...` until killed.
    # Label is passed as $argv[1] to keep quoting safe regardless of contents.
    fish -c '
        set -l label $argv[1]
        set -l frames . .. ...
        set -l i 1
        while true
            printf "\r%s%s\033[K" $label $frames[$i] >&2
            sleep 0.3
            set i (math "$i % 3 + 1")
        end
    ' "$label" &
    set -g __oko_spinner_pid (jobs --last --pid)
end
