function __oko_run --description 'Invoke an oko command, redirecting to --log file when active'
    set -l fn $argv[1]
    set -l rest $argv[2..-1]

    if set -q __oko_log_file
        $fn $rest >>$__oko_log_file 2>&1
    else
        $fn $rest
    end
end
