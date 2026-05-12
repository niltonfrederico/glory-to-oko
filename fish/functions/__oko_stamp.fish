function __oko_stamp --description 'ASCII stamp for the Department'
    # Usage: __oko_stamp approved|rejected|inspected [label]
    set -l kind $argv[1]
    set -l label $argv[2]
    set -l red (set_color -o red)
    set -l green (set_color -o green)
    set -l yellow (set_color -o yellow)
    set -l dim (set_color brblack)
    set -l reset (set_color normal)

    switch $kind
        case approved
            echo -e "$green   ┌──────────────────────┐$reset"
            echo -e "$green   │      APPROVED        │$reset"
            echo -e "$green   │  ★    О К    ★       │$reset"
            echo -e "$green   │  Документы в порядке │$reset"
            echo -e "$green   └──────────────────────┘$reset $dim$label$reset"
        case rejected
            echo -e "$red   ┌──────────────────────┐$reset"
            echo -e "$red   │      REJECTED        │$reset"
            echo -e "$red   │  ✖    Н Е Т    ✖     │$reset"
            echo -e "$red   │Документы не в порядке│$reset"
            echo -e "$red   └──────────────────────┘$reset $dim$label$reset"
        case inspected
            echo -e "$yellow   ┌──────────────────────┐$reset"
            echo -e "$yellow   │     INSPECTED        │$reset"
            echo -e "$yellow   │  ◉   ПРОВЕРЕНО   ◉   │$reset"
            echo -e "$yellow   └──────────────────────┘$reset $dim$label$reset"
        case '*'
            echo "[$kind] $label"
    end
end
