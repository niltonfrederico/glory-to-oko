---
description: Preenche descrições (PT-BR, one-liner) faltantes em pkgs/manifest.yaml
---

Sua tarefa: percorrer `pkgs/manifest.yaml` e adicionar o campo `description` em toda entrada que ainda não o tiver.

## Regras

- **Idioma**: PT-BR.
- **Tamanho**: one-liner curto (~60–80 chars). Sem ponto final. Sem aspas dentro do texto que quebrem o inline YAML.
- **Conteúdo**: o que o pacote *faz*, não como se instala. Evite "biblioteca para..." quando puder começar pelo objeto/ação (ex.: `editor de texto modal` > `software que é um editor de texto modal`).
- **Forma**: manter o estilo inline `{ name: X, manager: Y, description: "..." }`. Não reordenar entradas, não mudar managers.
- **Pacotes namespaced** (`steipete/tap/gogcli`, `yakitrak/yakitrak/obsidian-cli`): descrever o pacote-fim, não o tap.
- **Faltantes** = entradas sem chave `description`. Ignorar as que já tiverem (não reescrever).

## Como descobrir o que o pacote faz

Ordem de preferência:
1. `pacman -Si <name>` (oficial/Chaotic-AUR) ou `paru -Si <name>` (AUR) — campo `Description`.
2. `brew info <name>` para entradas com `manager: brew`.
3. `snap info <name>` para `manager: snap`.
4. Se ainda assim incerto, web search rápido. Não invente.

Traduza/condense pro PT-BR — não copie literal o Description em inglês.

## Batching

Se houver muitos faltantes, processa em lotes (~15–20 por vez) pra não estourar tempo. Reporta no fim quantos foram preenchidos e quantos restam.

## Saída

Edição direta em `pkgs/manifest.yaml`. Nenhum arquivo novo. Ao terminar o lote, mensagem curta no chat: `preenchidos: N | restantes: M`.
