function __oko_do --description 'Execute install/remove via a specific manager. Accepts one or more pkgs.'
    # Usage: __oko_do install|remove <manager> <pkg1> [pkg2 ...]
    set -l action $argv[1]
    set -l manager $argv[2]
    set -l pkgs $argv[3..]

    if test (count $pkgs) -eq 0
        return 1
    end

    set -l cmd (__oko_config command $manager)
    set -l args (__oko_config args $manager)
    set -l use_sudo 0
    if __oko_config sudoer $manager
        set use_sudo 1
    end

    switch $action
        case install
            switch $manager
                case brew
                    __oko_do_run $use_sudo $cmd $args install -- $pkgs
                case uvx
                    for p in $pkgs
                        __oko_do_run $use_sudo $cmd $args tool install -- $p
                        or return $status
                    end
                case pipx
                    for p in $pkgs
                        __oko_do_run $use_sudo $cmd $args install -- $p
                        or return $status
                    end
                case npm
                    __oko_do_run $use_sudo $cmd $args install -g -- $pkgs
                case paru
                    __oko_do_run $use_sudo $cmd $args -S --needed --noconfirm -- $pkgs
                case snap
                    for p in $pkgs
                        __oko_do_run $use_sudo $cmd $args install -- $p
                        or return $status
                    end
                case '*'
                    return 1
            end
        case remove
            switch $manager
                case brew
                    __oko_do_run $use_sudo $cmd $args uninstall -- $pkgs
                case uvx
                    for p in $pkgs
                        __oko_do_run $use_sudo $cmd $args tool uninstall -- $p
                        or return $status
                    end
                case pipx
                    for p in $pkgs
                        __oko_do_run $use_sudo $cmd $args uninstall -- $p
                        or return $status
                    end
                case npm
                    __oko_do_run $use_sudo $cmd $args uninstall -g -- $pkgs
                case paru
                    __oko_do_run $use_sudo $cmd $args -Rns --noconfirm -- $pkgs
                case snap
                    __oko_do_run $use_sudo $cmd $args remove --purge -- $pkgs
                case '*'
                    return 1
            end
        case '*'
            return 1
    end
end

function __oko_do_run --description 'Run a command, optionally under sudo (first arg: 1|0)'
    set -l use_sudo $argv[1]
    set -l rest $argv[2..]
    if test "$use_sudo" = 1
        sudo $rest
    else
        $rest
    end
end
