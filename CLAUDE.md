# Garuda — operações no host

Repo de apoio pra gerenciar o sistema operacional do operador (Garuda Linux, KDE/Wayland, fish): buscar informação, modificar config, escrever guias de como modificar.

## Configuração herdada

Este projeto **estende** o setup global do Claude Code. Em caso de conflito, **as instruções deste arquivo (e dos imports abaixo) sobrepõem** o global.

@~/.claude/CLAUDE.md
@~/.claude/languages/fish.md

## Stack

- **Host**: Garuda Linux (Arch-based), kernel zen, systemd
- **Shell**: fish 4.7.1 — **shell de operação obrigatório neste repo**
- **DE**: KDE Plasma sobre Wayland (compositor `kwin_wayland`)
- **Package manager**: pacman / paru
- **Tooling**: `plaguedoctor` (aliasado como `pd`) — CLI de inspeção/gestão do sistema

## Convenções específicas deste projeto

- **Use fish, não bash**, em qualquer comando que você executar via Bash tool. Sintaxe (`set`, `and`/`or`, `$status`, `$argv`, blocos `begin`/`end`), redireção (`^` vs `2>`), funções em `~/.config/fish/functions/`. Veja `@~/.claude/languages/fish.md` pra o resto.
- **Antes de propor mudança no sistema**, consulte `pd info system --ai` — retorna JSON com hardware, OS, GUI, terminal, apps instalados. Use isso como source-of-truth pro estado atual do host em vez de assumir.
- **Permissões fish liberadas**: pode rodar comandos fish sem confirmação. Ações destrutivas (pacman -R, systemctl disable em unit crítica, rm -rf fora de `/tmp` e do diretório raiz deste projeto, mudança em config global) continuam exigindo confirmação explícita — o blast radius do host inteiro é alto.
- **Guias**: quando o usuário pedir "como faço pra X", escreva o guia em PT-BR, com comandos fish executáveis, e indique claramente o que é reversível vs destrutivo.

## Notas para o Claude

- O host é daily-driver do operador — uptime e estabilidade importam. Trate mudanças no sistema com a mesma seriedade de produção.
- `pd` está em desenvolvimento ativo (`plaguedoctor`). Se um subcomando não existir, não invente — surface o gap.
- `.remember/` é estado do plugin `remember`; não comitar mexidas nele.
