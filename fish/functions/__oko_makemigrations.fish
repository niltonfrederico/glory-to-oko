function __oko_makemigrations --description 'Generate a new migration from manifest vs history'
    set -l name ""
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --name -n
                set i (math $i + 1)
                set name $argv[$i]
            case '--name=*'
                set name (string replace -- '--name=' '' $argv[$i])
            case -h --help
                echo "Usage: oko makemigrations [--name slug]"
                return 0
        end
        set i (math $i + 1)
    end

    set -l mig_dir (__oko_paths migrations)
    set -l manifest (__oko_paths manifest)

    # Build history state: replay every migration's install/remove operations
    set -l hist_file (mktemp)
    echo "{}" >$hist_file
    set -l mig_files $mig_dir/*.yaml
    if not test -e $mig_files[1] 2>/dev/null
        set mig_files
    end
    for f in $mig_files
        # install ops: set hist[name] = manager
        for entry in (yq -o=json -I=0 '.operations[] | select(.action == "install") | .packages[]' $f 2>/dev/null)
            set -l n (echo $entry | yq -r '.name')
            set -l m (echo $entry | yq -r '.manager // ""')
            yq -i ".\"$n\" = \"$m\"" $hist_file
        end
        # remove ops: delete from hist
        for entry in (yq -o=json -I=0 '.operations[] | select(.action == "remove") | .packages[]' $f 2>/dev/null)
            set -l n (echo $entry | yq -r '.name')
            yq -i "del(.\"$n\")" $hist_file
        end
    end

    # Compare with current manifest
    set -l manifest_names (yq -r '.packages[].name' $manifest | sort -u)
    set -l hist_names (yq -r 'keys | .[]' $hist_file | sort -u)

    set -l to_install
    set -l to_remove
    for n in $manifest_names
        if not contains -- $n $hist_names
            set to_install $to_install $n
        end
    end
    for n in $hist_names
        if not contains -- $n $manifest_names
            set to_remove $to_remove $n
        end
    end

    rm -f $hist_file

    if test (count $to_install) -eq 0 -a (count $to_remove) -eq 0
        __oko_say ok "Sem novas operações para registrar, camarada. Tudo em ordem."
        return 0
    end

    # Next migration id
    set -l next_num "0001"
    if test (count $mig_files) -gt 0
        set -l last $mig_files[-1]
        set -l n (basename $last | string sub -l 4)
        set next_num (printf "%04d" (math "$n + 1"))
    end

    if test -z "$name"
        set name auto
    end
    set name (string replace -ra '[^a-z0-9]+' '-' (string lower $name))
    set -l slug "$next_num"_"$name"
    set -l mig_file $mig_dir/$slug.yaml
    set -l ts (date -Iseconds)

    echo "id: \"$slug\"" >$mig_file
    echo "created: \"$ts\"" >>$mig_file
    echo "description: \"Auto-captured diff (manifest vs history).\"" >>$mig_file
    echo "operations:" >>$mig_file
    if test (count $to_install) -gt 0
        echo "  - action: install" >>$mig_file
        echo "    packages:" >>$mig_file
        for n in $to_install
            set -l m (__oko_manifest manager-of $n)
            echo "      - { name: $n, manager: $m }" >>$mig_file
        end
    end
    if test (count $to_remove) -gt 0
        echo "  - action: remove" >>$mig_file
        echo "    packages:" >>$mig_file
        for n in $to_remove
            echo "      - { name: $n }" >>$mig_file
        end
    end

    __oko_stamp approved "migration $slug registrada"
    __oko_say ok "Documento arquivado em $mig_file"
    __oko_say info (count $to_install)" install · "(count $to_remove)" remove"
end
