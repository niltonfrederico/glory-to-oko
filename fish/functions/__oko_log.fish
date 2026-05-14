function __oko_log --description 'Emit a structured oko diagnostic log line'
    if test (count $argv) -lt 3
        echo "__oko_log: usage: __oko_log <level> <dotted.path> <message...>" >&2
        return 2
    end

    set -l level (string upper -- $argv[1])
    set -l path $argv[2]
    set -l message (string join ' ' -- $argv[3..-1])

    if test "$level" = DEBUG; and not set -q __oko_debug
        return 0
    end

    set -l timestamp (date '+%F %T')

    set -l use_color 1
    if set -q __oko_log_file; or set -q NO_COLOR; or not isatty stderr
        set use_color 0
    end

    set -l level_color normal
    switch $level
        case DEBUG
            set level_color brblack
        case INFO
            set level_color cyan
        case WARN
            set level_color yellow
        case ERROR
            set level_color red
    end

    set -l body (__oko_log_format_message $use_color -- $message)

    set -l line
    if test $use_color -eq 1
        set line (set_color brblack)"[$timestamp]"(set_color normal)" "(set_color --bold $level_color)"[ЖУРНАЛ $level]"(set_color normal)" "(set_color brblack)"[$path]"(set_color normal)" $body"
    else
        set line "[$timestamp] [ЖУРНАЛ $level] [$path] $body"
    end

    if set -q __oko_log_file
        echo -- $line >>$__oko_log_file
    else
        echo -- $line >&2
    end
end

function __oko_log_format_message --description 'Render **bold** spans inside a log message'
    set -l use_color $argv[1]
    set -l text (string join ' ' -- $argv[3..-1])

    if test $use_color -ne 1
        string replace --all '**' '' -- $text
        return 0
    end

    set -l parts (string split '**' -- $text)
    set -l out
    set -l i 1
    for part in $parts
        if test (math "$i % 2") -eq 0
            set -a out (set_color --bold)$part(set_color normal)
        else
            set -a out $part
        end
        set i (math $i + 1)
    end
    string join '' -- $out
end
