function __oko_manifest --description 'Read/write the package manifest'
    set -l action $argv[1]
    set -l file (__oko_paths manifest)

    if not test -f "$file"
        echo "version: 1" >$file
        echo "packages: []" >>$file
    end

    switch $action
        case has
            set -l name $argv[2]
            set -l found (yq ".packages[] | select(.name == \"$name\") | .name" $file)
            test -n "$found"
        case manager-of
            set -l name $argv[2]
            yq -r ".packages[] | select(.name == \"$name\") | .manager" $file
        case add
            set -l name $argv[2]
            set -l manager $argv[3]
            if __oko_manifest has $name
                return 0
            end
            yq -i ".packages += [{\"name\":\"$name\",\"manager\":\"$manager\"}]" $file
        case remove
            set -l name $argv[2]
            yq -i "del(.packages[] | select(.name == \"$name\"))" $file
        case list
            yq -r '.packages[] | .name + " " + .manager' $file
        case names
            yq -r '.packages[].name' $file
        case '*'
            __oko_say nope "manifest: unknown action $action"
            return 1
    end
end
