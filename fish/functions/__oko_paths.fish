function __oko_paths --description 'Resolve oko home paths'
    set -l home $OKO_HOME
    if test -z "$home"
        # Derive default from this script's location: <repo>/fish/functions/__oko_paths.fish → <repo>/pkgs
        set -l self (realpath (status filename))
        set home (dirname (dirname (dirname $self)))/pkgs
    end
    switch $argv[1]
        case home
            echo $home
        case manifest
            echo $home/manifest.yaml
        case state
            echo $home/state.yaml
        case migrations
            echo $home/migrations
        case '*'
            echo $home
    end
end
