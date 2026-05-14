function oko-update --description 'Re-link oko functions and completions from this repo into ~/.config/fish'
    set -l self (realpath (status filename))
    set -l src_root (dirname (dirname $self))
    set -l fn_src $src_root/functions
    set -l cp_src $src_root/completions
    set -l fn_dst ~/.config/fish/functions
    set -l cp_dst ~/.config/fish/completions

    if not test -d $fn_src
        __oko_say nope "Fonte não encontrada: $fn_src"
        return 1
    end

    mkdir -p $fn_dst $cp_dst

    set -l fn_count 0
    for f in $fn_src/*.fish
        ln -sf $f $fn_dst/(basename $f)
        set fn_count (math $fn_count + 1)
    end

    set -l cp_count 0
    if test -d $cp_src
        for f in $cp_src/*.fish
            ln -sf $f $cp_dst/(basename $f)
            set cp_count (math $cp_count + 1)
        end
    end

    __oko_header
    __oko_say ok "$fn_count function(s) sincronizada(s) ← $fn_src"
    __oko_say ok "$cp_count completion(s) sincronizada(s) ← $cp_src"

    set -l cfg (__oko_config_path)
    if test -f $cfg
        __oko_say hush "Config já existe em $cfg — preservada."
    else
        __oko_config_init
        __oko_say ok "Config inicial em $cfg"
    end

    __oko_say hush "Abra um novo shell fish ou rode 'source ~/.config/fish/config.fish' para recarregar."
end
