function __oko_probe --description 'Probe a package against a manager'
    # Usage: __oko_probe <kind> <manager> <pkg>
    # kind: available  → exists in the manager's source/repo
    #       installed  → already installed locally
    set -l kind $argv[1]
    set -l manager $argv[2]
    set -l pkg $argv[3]

    switch $kind
        case available
            switch $manager
                case brew
                    brew formulae 2>/dev/null | grep -qFx -- $pkg; and return 0
                    brew casks 2>/dev/null | grep -qFx -- $pkg; and return 0
                    # tap-qualified (e.g. user/tap/pkg)
                    if string match -q '*/*' -- $pkg
                        brew info --formula -- $pkg >/dev/null 2>&1; and return 0
                    end
                    return 1
                case uvx pipx
                    set -l code (curl -fsS -o /dev/null -w '%{http_code}' "https://pypi.org/pypi/$pkg/json" 2>/dev/null)
                    test "$code" = 200
                case npm
                    npm view --silent -- $pkg name >/dev/null 2>&1
                case paru
                    paru -Si -- $pkg >/dev/null 2>&1
                case snap
                    snap info -- $pkg 2>/dev/null | grep -q '^name:'
                case '*'
                    return 1
            end
        case installed
            switch $manager
                case brew
                    brew list --formula -1 2>/dev/null | grep -qFx -- $pkg; and return 0
                    brew list --cask -1 2>/dev/null | grep -qFx -- $pkg; and return 0
                    return 1
                case uvx
                    uv tool list 2>/dev/null | awk '{print $1}' | grep -qFx -- $pkg
                case pipx
                    pipx list --short 2>/dev/null | awk '{print $1}' | grep -qFx -- $pkg
                case npm
                    npm ls -g --depth=0 --parseable 2>/dev/null | grep -qE "/$pkg\$"
                case paru
                    pacman -Qq -- $pkg >/dev/null 2>&1
                case snap
                    snap list -- $pkg >/dev/null 2>&1
                case '*'
                    return 1
            end
        case '*'
            return 1
    end
end
