function __oko_do --description 'Execute install/remove via a specific manager'
    # Usage: __oko_do install|remove <manager> <pkg>
    set -l action $argv[1]
    set -l manager $argv[2]
    set -l pkg $argv[3]

    switch $action
        case install
            switch $manager
                case brew
                    brew install -- $pkg
                case uvx
                    uv tool install -- $pkg
                case pipx
                    pipx install -- $pkg
                case npm
                    npm install -g -- $pkg
                case paru
                    paru -S --needed --noconfirm -- $pkg
                case snap
                    sudo snap install -- $pkg
                case '*'
                    return 1
            end
        case remove
            switch $manager
                case brew
                    brew uninstall -- $pkg
                case uvx
                    uv tool uninstall -- $pkg
                case pipx
                    pipx uninstall -- $pkg
                case npm
                    npm uninstall -g -- $pkg
                case paru
                    paru -Rns --noconfirm -- $pkg
                case snap
                    sudo snap remove -- $pkg
                case '*'
                    return 1
            end
        case '*'
            return 1
    end
end
