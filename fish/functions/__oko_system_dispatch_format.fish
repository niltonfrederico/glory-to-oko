function __oko_system_dispatch_format --description 'Route merged JSON to the right formatter'
    set -l fmt $argv[1]
    if test -z "$fmt"
        set fmt terminal
    end
    set -l fn __oko_system_format_$fmt
    if not functions -q $fn
        __oko_log error info.system "no formatter for **$fmt**"
        return 2
    end
    $fn
end
