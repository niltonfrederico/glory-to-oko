function __oko_resolve --description 'Find first manager where a pkg is available (priority order)'
    # Usage: __oko_resolve <pkg>
    # Prints manager name on stdout if found; exits 1 otherwise.
    set -l pkg $argv[1]
    for m in (__oko_config managers)
        if __oko_probe available $m $pkg
            echo $m
            return 0
        end
    end
    return 1
end
