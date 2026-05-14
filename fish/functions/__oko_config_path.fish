function __oko_config_path --description 'Resolve oko user config path'
    if test -n "$OKO_CONFIG"
        echo $OKO_CONFIG
        return 0
    end
    echo $HOME/.oko/config.yaml
end
