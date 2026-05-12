function __oko_state --description 'Read/write the migration applied-state'
    set -l action $argv[1]
    set -l file (__oko_paths state)

    if not test -f "$file"
        echo "applied: []" >$file
    end

    switch $action
        case applied
            yq -r '.applied[].id' $file
        case has
            set -l id $argv[2]
            set -l found (yq ".applied[] | select(.id == \"$id\") | .id" $file)
            test -n "$found"
        case mark
            set -l id $argv[2]
            set -l ts (date -Iseconds)
            if __oko_state has $id
                return 0
            end
            yq -i ".applied += [{\"id\":\"$id\",\"applied_at\":\"$ts\"}]" $file
        case '*'
            __oko_say nope "state: unknown action $action"
            return 1
    end
end
