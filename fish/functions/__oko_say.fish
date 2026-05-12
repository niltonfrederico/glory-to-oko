function __oko_say --description 'Themed printer for the Department'
    # Usage: __oko_say <mood> <message...>
    # moods: info | ok | warn | nope | hush | inspector
    set -l mood $argv[1]
    set -l msg (string join ' ' $argv[2..])

    set -l red (set_color -o red)
    set -l yellow (set_color yellow)
    set -l beige (set_color cyan)
    set -l dim (set_color brblack)
    set -l reset (set_color normal)

    switch $mood
        case info
            printf '%s[ОТДЕЛ]%s %s\n' $beige $reset $msg
        case ok
            printf '%s[Хорошо]%s %s\n' $yellow $reset $msg
        case warn
            printf '%s[Внимание]%s %s\n' $red $reset $msg
        case nope
            printf '%s[Нет]%s %s\n' $red $reset $msg
        case hush
            printf '%s[…] %s%s\n' $dim $msg $reset
        case inspector
            printf '%s[Inspetor]%s %s\n' $beige $reset $msg
        case '*'
            printf '%s\n' $msg
    end
end
