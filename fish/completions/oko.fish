function __oko_no_command
    set -l cmd (commandline -opc)
    test (count $cmd) -eq 1
end

function __oko_using_command
    set -l cmd (commandline -opc)
    test (count $cmd) -ge 2
    and contains -- $cmd[2] $argv
end

function __oko_manifest_pkgs
    set -l file (__oko_paths manifest 2>/dev/null)
    test -f "$file"
    or return 0
    yq -r '.packages[] | .name + "\t" + .manager + ": " + (.description // "")' $file 2>/dev/null
end

complete -c oko -f

complete -c oko -n __oko_no_command -a install -d 'Declarar entrada (redige migration)'
complete -c oko -n __oko_no_command -a i -d 'alias: install'
complete -c oko -n __oko_no_command -a remove -d 'Declarar saída (redige migration)'
complete -c oko -n __oko_no_command -a r -d 'alias: remove'
complete -c oko -n __oko_no_command -a check -d 'Inspecionar documentos'
complete -c oko -n __oko_no_command -a c -d 'alias: check'
complete -c oko -n __oko_no_command -a upgrade -d 'Atualizar managers em ordem'
complete -c oko -n __oko_no_command -a u -d 'alias: upgrade'
complete -c oko -n __oko_no_command -a system -d 'Snapshot do host (JSON/YAML/CSV/terminal)'
complete -c oko -n __oko_no_command -a s -d 'alias: system'
complete -c oko -n __oko_no_command -a makemigrations -d 'Arquivar diff manifest×histórico'
complete -c oko -n __oko_no_command -a mm -d 'alias: makemigrations'
complete -c oko -n __oko_no_command -a migrate -d 'Aplicar migrations pendentes'
complete -c oko -n __oko_no_command -a mi -d 'alias: migrate'
complete -c oko -n __oko_no_command -a help -d Ajuda

# remove/check completam a partir do manifest; fish reavalia por token → múltiplos args OK.
complete -c oko -n '__oko_using_command remove r check c' -a '(__oko_manifest_pkgs)'

# --manager flag para install/remove/upgrade — lista vem do config.yaml
complete -c oko -n '__oko_using_command install i remove r upgrade u' \
    -l manager -d 'Forçar manager' -x -a '(__oko_config managers 2>/dev/null)'

# upgrade flags
complete -c oko -n '__oko_using_command upgrade u' -l dry-run -s n -d 'Mostrar sem executar'

# system flags (mirror plaguedoctor info system)
complete -c oko -n '__oko_using_command system s' -s A -l ai -d 'JSON LLM-friendly'
complete -c oko -n '__oko_using_command system s' -s S -l no-sudo -d 'Sem prompt sudo'
complete -c oko -n '__oko_using_command system s' -s o -l output -x -a 'json yaml csv' -d Formato
complete -c oko -n '__oko_using_command system s' -s H -l hardware -d CPU/RAM/GPU/discos
complete -c oko -n '__oko_using_command system s' -s O -l os -d Distro/kernel/libc
complete -c oko -n '__oko_using_command system s' -s g -l gui -d Desktop/sessão
complete -c oko -n '__oko_using_command system s' -s t -l terminal -d Emulador/shell
complete -c oko -n '__oko_using_command system s' -s a -l apps -d 'Apps curados'
complete -c oko -n '__oko_using_command system s' -l storage -d FS/btrfs/snapper/swap
complete -c oko -n '__oko_using_command system s' -l services -d 'Units falhadas/lentas'
complete -c oko -n '__oko_using_command system s' -l pkg -d Pacman/AUR
complete -c oko -n '__oko_using_command system s' -l boot -d 'Loader/kernel cmdline'
complete -c oko -n '__oko_using_command system s' -l network -d NM/DNS/hostname
complete -c oko -n '__oko_using_command system s' -l security -d Firewall/AppArmor/LUKS
complete -c oko -n '__oko_using_command system s' -l containers -d docker/podman/distrobox
complete -c oko -n '__oko_using_command system s' -l locale -d Locale/timezone/NTP
complete -c oko -n '__oko_using_command system s' -l theming -d GTK/icones/fontes
