function __oko_owner --description 'Find the manager that currently owns an installed pkg'
    # Usage: __oko_owner <pkg>
    set -l pkg $argv[1]
    for m in (__oko_config managers)
        if __oko_probe installed $m $pkg
            echo $m
            return 0
        end
    end
    return 1
end
