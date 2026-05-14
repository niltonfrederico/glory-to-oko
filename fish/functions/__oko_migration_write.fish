function __oko_migration_write --description 'Write a migration file from collected ops. Args: <name> <install:n=m,...> <remove:n=m,...>'
    # Args:
    #   $argv[1] = slug name (e.g. "install" or "remove")
    #   $argv[2] = comma-separated install ops as "name=manager"
    #   $argv[3] = comma-separated remove ops as "name=manager"
    # Prints the path to the created migration file on stdout.
    set -l name $argv[1]
    set -l installs_csv $argv[2]
    set -l removes_csv $argv[3]

    set -l mig_dir (__oko_paths migrations)
    mkdir -p $mig_dir
    set -l mig_files $mig_dir/*.yaml
    if not test -e $mig_files[1] 2>/dev/null
        set mig_files
    end

    set -l next_num 0001
    if test (count $mig_files) -gt 0
        set -l last $mig_files[-1]
        set -l n (basename $last | string sub -l 4)
        set next_num (printf "%04d" (math "$n + 1"))
    end

    set name (string replace -ra '[^a-z0-9]+' '-' (string lower $name))
    set -l slug "$next_num"_"$name"
    set -l mig_file $mig_dir/$slug.yaml
    set -l ts (date -Iseconds)

    echo "id: \"$slug\"" >$mig_file
    echo "created: \"$ts\"" >>$mig_file
    echo "description: \"Drafted by oko $name.\"" >>$mig_file
    echo "operations:" >>$mig_file

    if test -n "$installs_csv"
        echo "  - action: install" >>$mig_file
        echo "    packages:" >>$mig_file
        for pair in (string split ',' $installs_csv)
            set -l n (string split '=' $pair)[1]
            set -l m (string split '=' $pair)[2]
            echo "      - { name: $n, manager: $m }" >>$mig_file
        end
    end

    if test -n "$removes_csv"
        echo "  - action: remove" >>$mig_file
        echo "    packages:" >>$mig_file
        for pair in (string split ',' $removes_csv)
            set -l n (string split '=' $pair)[1]
            set -l m (string split '=' $pair)[2]
            if test -n "$m"
                echo "      - { name: $n, manager: $m }" >>$mig_file
            else
                echo "      - { name: $n }" >>$mig_file
            end
        end
    end

    echo $mig_file
end

function __oko_migration_write_upgrade --description 'Write an upgrade-audit migration. Args: <manager:ok:count,...>'
    # Each entry in the CSV is "<manager>:<ok>:<packages_count>".
    # Returns the path to the created migration on stdout.
    set -l rows_csv $argv[1]

    set -l mig_dir (__oko_paths migrations)
    mkdir -p $mig_dir
    set -l mig_files $mig_dir/*.yaml
    if not test -e $mig_files[1] 2>/dev/null
        set mig_files
    end

    set -l next_num 0001
    if test (count $mig_files) -gt 0
        set -l last $mig_files[-1]
        set -l n (basename $last | string sub -l 4)
        set next_num (printf "%04d" (math "$n + 1"))
    end

    set -l slug "$next_num"_upgrade
    set -l mig_file $mig_dir/$slug.yaml
    set -l ts (date -Iseconds)

    echo "id: \"$slug\"" >$mig_file
    echo "created: \"$ts\"" >>$mig_file
    echo "description: \"Drafted by oko upgrade.\"" >>$mig_file
    echo "operations:" >>$mig_file
    echo "  - action: upgrade" >>$mig_file
    echo "    managers:" >>$mig_file
    for row in (string split ',' $rows_csv)
        set -l parts (string split ':' $row)
        set -l name $parts[1]
        set -l ok $parts[2]
        set -l count $parts[3]
        echo "      - { name: $name, ok: $ok, packages_count: $count }" >>$mig_file
    end

    echo $mig_file
end
