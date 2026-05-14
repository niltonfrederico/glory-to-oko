function __oko_json_kv --description 'Build a flat JSON object from (key value) pairs; empty values become null'
    set -l n (count $argv)
    if test (math "$n % 2") -ne 0
        echo "__oko_json_kv: arg count must be even (key value pairs)" >&2
        return 2
    end

    if test $n -eq 0
        echo '{}'
        return 0
    end

    # Each pair becomes `--arg kN <key> --arg vN <value>` and contributes
    # `($kN): (if $vN == "" then null else $vN end)` to the filter. Empty
    # string sentinel for null lets collectors return `(missing_call)` as
    # `""` without conditional jq logic in every site.
    set -l jq_args
    set -l filter '{'
    set -l i 1
    set -l idx 1
    while test $i -le $n
        set -l key $argv[$i]
        set -l val $argv[(math $i + 1)]
        set -l kv k$idx
        set -l vv v$idx
        set -a jq_args --arg $kv $key --arg $vv $val
        set -l part "(\$$kv): (if \$$vv == \"\" then null else \$$vv end)"
        if test $idx -eq 1
            set filter $filter$part
        else
            set filter "$filter, $part"
        end
        set idx (math $idx + 1)
        set i (math $i + 2)
    end
    set filter $filter'}'

    jq -n $jq_args $filter
end
