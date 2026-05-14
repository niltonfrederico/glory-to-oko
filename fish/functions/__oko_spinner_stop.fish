function __oko_spinner_stop --description 'Stop the oko dots spinner and clear the line'
    if not set -q __oko_spinner_pid
        return 0
    end

    set -l pid $__oko_spinner_pid
    set -e __oko_spinner_pid

    kill $pid 2>/dev/null
    wait $pid 2>/dev/null

    if isatty stderr
        printf '\r\033[K' >&2
    end
end
