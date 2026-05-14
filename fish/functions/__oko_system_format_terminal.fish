function __oko_system_format_terminal --description 'Pretty-print the merged system JSON to a TTY with grouped sections'
    set -l use_color 1
    if set -q __oko_log_file; or set -q NO_COLOR; or not isatty stdout
        set use_color 0
    end

    set -l c_section ''
    set -l c_key ''
    set -l c_dim ''
    set -l c_reset ''
    if test $use_color -eq 1
        set c_section (set_color --bold cyan)
        set c_key (set_color green)
        set c_dim (set_color brblack)
        set c_reset (set_color normal)
    end

    # Stream the input JSON once: emit a header per top-level key, then
    # walk every leaf scalar under it as `key.path: value`. Null values
    # render as a dim placeholder so they're visible without being noisy.
    jq -r '
        to_entries[]
        | "__SECTION__\(.key)",
          (
            .value
            | [paths(scalars) as $p | "\($p | join(".")): \(getpath($p) | tostring)"]
            | .[]
          )
    ' | while read -l line
        if string match -q '__SECTION__*' -- $line
            set -l name (string sub --start 12 -- $line)
            echo
            echo $c_section"## $name"$c_reset
        else
            set -l key (string split -m1 ': ' -- $line)[1]
            set -l val (string split -m1 ': ' -- $line)[2]
            if test "$val" = null
                set val "$c_dim—$c_reset"
            end
            echo "  $c_key$key$c_reset: $val"
        end
    end
end
