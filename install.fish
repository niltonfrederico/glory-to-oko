#!/usr/bin/env fish
# Departamento de Operações e Controle · primeira nomeação do Inspetor
#
# Usado uma única vez, quando `oko-update` ainda não está disponível no
# host (ou está apontando para symlinks quebrados). Idempotente — pode
# ser re-executado sem dano. Após a primeira corrida, prefira
# `oko-update` para resincronizações futuras.
#
#   fish install.fish

set -l self (realpath (status filename))
set -l repo (dirname $self)
set -l fn_src $repo/fish/functions
set -l cp_src $repo/fish/completions
set -l fn_dst $HOME/.config/fish/functions
set -l cp_dst $HOME/.config/fish/completions

set -l red (set_color -o red)
set -l yellow (set_color yellow)
set -l cyan (set_color cyan)
set -l dim (set_color brblack)
set -l reset (set_color normal)

echo
echo "$red╔══════════════════════════════════════════════════════════════╗$reset"
echo "$red║$reset $yellow ОТДЕЛ ОПЕРАЦИЙ И КОНТРОЛЯ · ПЕРВАЯ ПРИСЯГА                 $reset $red║$reset"
echo "$red║$reset $dim Primeira nomeação — symlinks absolutos                    $reset $red║$reset"
echo "$red╚══════════════════════════════════════════════════════════════╝$reset"
echo

if not test -d $fn_src
    echo "$red[Нет]$reset Fonte de funções não encontrada: $fn_src" >&2
    exit 1
end

mkdir -p $fn_dst $cp_dst

set -l fn_count 0
for f in $fn_src/*.fish
    ln -sfn $f $fn_dst/(basename $f)
    set fn_count (math $fn_count + 1)
end

set -l cp_count 0
if test -d $cp_src
    for f in $cp_src/*.fish
        ln -sfn $f $cp_dst/(basename $f)
        set cp_count (math $cp_count + 1)
    end
end

printf '%s[ОТДЕЛ]%s %d function(s) linkada(s) ← %s\n' $cyan $reset $fn_count $fn_src
printf '%s[ОТДЕЛ]%s %d completion(s) linkada(s) ← %s\n' $cyan $reset $cp_count $cp_src

set -l cfg $HOME/.oko/config.yaml
if not test -f $cfg
    mkdir -p (dirname $cfg)
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
        '    sudoer: true' >$cfg
    printf '%s[ОТДЕЛ]%s Config semeada em %s\n' $cyan $reset $cfg
else
    printf '%s[…] Config existente preservada em %s%s\n' $dim $cfg $reset
end

echo
echo "$dim Abra um novo shell fish (ou \`source ~/.config/fish/config.fish\`) para começar."
echo " Daqui em diante use \`oko-update\` para resincronizar."
echo " Документы пожалуйста.$reset"
echo
