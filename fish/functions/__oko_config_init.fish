function __oko_config_init --description 'Seed ~/.oko/config.yaml with default managers if absent'
    set -l file (__oko_config_path)
    set -l dir (dirname $file)

    if test -f $file
        return 0
    end

    mkdir -p $dir

    printf '%s\n' \
        'version: 1' \
        'package_managers:' \
        '  brew:' \
        '    command: brew' \
        '    args: []' \
        '    priority: 1' \
        '    sudoer: false' \
        '  uvx:' \
        '    command: uv' \
        '    args: []' \
        '    priority: 2' \
        '    sudoer: false' \
        '  pipx:' \
        '    command: pipx' \
        '    args: []' \
        '    priority: 3' \
        '    sudoer: false' \
        '  npm:' \
        '    command: npm' \
        '    args: []' \
        '    priority: 4' \
        '    sudoer: false' \
        '  paru:' \
        '    command: paru' \
        '    args: []' \
        '    priority: 5' \
        '    sudoer: false' \
        '  snap:' \
        '    command: snap' \
        '    args: []' \
        '    priority: 6' \
        '    sudoer: true' >$file

end
