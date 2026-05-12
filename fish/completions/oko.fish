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

complete -c oko -n __oko_no_command -a install        -d 'Declarar entrada (redige migration)'
complete -c oko -n __oko_no_command -a i              -d 'alias: install'
complete -c oko -n __oko_no_command -a remove         -d 'Declarar saída (redige migration)'
complete -c oko -n __oko_no_command -a r              -d 'alias: remove'
complete -c oko -n __oko_no_command -a check          -d 'Inspecionar documentos'
complete -c oko -n __oko_no_command -a c              -d 'alias: check'
complete -c oko -n __oko_no_command -a makemigrations -d 'Arquivar diff manifest×histórico'
complete -c oko -n __oko_no_command -a mm             -d 'alias: makemigrations'
complete -c oko -n __oko_no_command -a migrate        -d 'Aplicar migrations pendentes'
complete -c oko -n __oko_no_command -a mi             -d 'alias: migrate'
complete -c oko -n __oko_no_command -a help           -d 'Ajuda'

# remove/check completam a partir do manifest; fish reavalia por token → múltiplos args OK.
complete -c oko -n '__oko_using_command remove r check c' -a '(__oko_manifest_pkgs)'

# --manager flag para install/remove
complete -c oko -n '__oko_using_command install i remove r' \
    -l manager -d 'Forçar manager' -x -a 'brew uvx pipx npm paru snap'
