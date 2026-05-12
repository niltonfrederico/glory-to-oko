function __oko_do --description 'Execute install/remove via a specific manager. Accepts one or more pkgs.'
    # Usage: __oko_do install|remove <manager> <pkg1> [pkg2 ...]
    set -l action $argv[1]
    set -l manager $argv[2]
    set -l pkgs $argv[3..]

    if test (count $pkgs) -eq 0
        return 1
    end

    switch $action
        case install
            switch $manager
                case brew
                    brew install -- $pkgs
                case uvx
                    for p in $pkgs
                        uv tool install -- $p
                        or return $status
                    end
                case pipx
                    for p in $pkgs
                        pipx install -- $p
                        or return $status
                    end
                case npm
                    npm install -g -- $pkgs
                case paru
                    paru -S --needed --noconfirm -- $pkgs
                case snap
                    for p in $pkgs
                        sudo snap install -- $p
                        or return $status
                    end
                case '*'
                    return 1
            end
        case remove
            switch $manager
                case brew
                    brew uninstall -- $pkgs
                case uvx
                    for p in $pkgs
                        uv tool uninstall -- $p
                        or return $status
                    end
                case pipx
                    for p in $pkgs
                        pipx uninstall -- $p
                        or return $status
                    end
                case npm
                    npm uninstall -g -- $pkgs
                case paru
                    paru -Rns --noconfirm -- $pkgs
                case snap
                    sudo snap remove --purge -- $pkgs
                case '*'
                    return 1
            end
        case '*'
            return 1
    end
end
