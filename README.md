# Glory to Oko!

```
╔══════════════════════════════════════════════════════════════╗
║  ОТДЕЛ ОПЕРАЦИЙ И КОНТРОЛЯ · ДОКУМЕНТЫ ПОЖАЛУЙСТА            ║
║  Departamento de Operações e Controle                       ║
╚══════════════════════════════════════════════════════════════╝
```

> *"Não há pacotes ilegais — apenas papéis em desordem."*
> — Manual do Inspetor, edição revisada, capítulo 4

Repositório de controle interno do Camarada `[REDACTED]`. Toda admissão e deportação de pacotes neste estado-soberano (`[REDACTED]`, `[REDACTED]`, fish 4.7.1, `[REDACTED]`/Wayland) passa pelo carimbo do **Departamento**.

A doutrina é simples: **o manifesto é a verdade declarada, as migrations são o arquivo histórico, o sistema é apenas o reflexo material da burocracia.**

---

## Sumário

- [Doutrina](#doutrina)
- [Diretrizes](#diretrizes)
- [Procedimentos autorizados](#procedimentos-autorizados)
- [Instalação do Inspetor](#instalação-do-inspetor)
- [Layout do arquivo central](#layout-do-arquivo-central)
- [Dependências externas reconhecidas](#dependências-externas-reconhecidas)
- [Variáveis de Estado](#variáveis-de-estado)
- [Avisos finais](#avisos-finais)

**Documentos correlatos:**

- [`fish/README.md`](fish/README.md) — manual técnico interno do Inspetor
- [`LICENSE.md`](LICENSE.md) — Diretiva Interna Nº ███-Δ/█026 (uso, custódia, força maior)

---

## Doutrina

| Conceito        | Papel oficial                                                                 |
|-----------------|-------------------------------------------------------------------------------|
| `manifest.yaml` | Decreto vigente — o que **deve** estar instalado. Editável.                   |
| `migrations/`   | Arquivo Central — toda mudança decretada, em ordem, imutável.                 |
| `state.yaml`    | Livro de carimbos — quais decretos já foram executados no território.         |
| `oko`           | O Inspetor de fronteira. Único agente autorizado a aplicar movimentação.      |

Inspirado livremente em Django migrations. Adapatado ao ofício de portaria.

---

## Diretrizes

O Departamento opera sob seis bandeiras (na ordem de prioridade do Inspetor):

```
brew  →  uvx  →  pipx  →  npm  →  paru  →  snap
```

O Inspetor tenta na ordem. O primeiro que reconhecer o indivíduo recebe a custódia.

---

## Procedimentos autorizados

```fish
oko install <pkg…>      # admitir indivíduos pela fronteira
oko remove  <pkg…>      # deportar indivíduos
oko check   <pkg…>      # inspecionar documentos (read-only)
oko upgrade [--manager X | --dry-run]
                        # atualizar managers em ordem; arquiva migration de auditoria
oko system  [flags]     # snapshot do host (hardware/OS/GUI/apps/...) em JSON/YAML/CSV
oko makemigrations      # arquivar diff manifest × histórico
oko migrate             # aplicar decretos pendentes ao território
oko-update              # resincronizar o Inspetor + semear ~/.oko/config.yaml
```

`install` e `remove` **não tocam o território** diretamente. Eles atualizam o manifesto, redigem uma migration, e perguntam se o Inspetor deve aplicar agora. Negar descarta a migration — o manifesto fica marcado e o próximo `makemigrations` pode arquivá-la novamente, se ainda for de interesse do Estado.

`upgrade` toca o território (executa update/upgrade em cada manager declarado em `~/.oko/config.yaml`, na ordem de `priority`) e arquiva uma migration tipo `upgrade` — registro histórico, não replay. Em outro host, `oko migrate` reconhece esse tipo de migration mas não tenta retroceder versões: marca aplicada e segue.

`system` é puramente read-only: emite um relatório do estado do host. Sem header soviético no output estruturado (evita poluir JSON/YAML). Espelha 1:1 o antigo `pd info system`.

---

## Instalação do Inspetor

**Primeira nomeação** — symlinks na unha (substitua `<repo>` pelo caminho local do clone):

```fish
for f in <repo>/fish/functions/*.fish
    ln -sf $f ~/.config/fish/functions/(basename $f)
end
for f in <repo>/fish/completions/*.fish
    ln -sf $f ~/.config/fish/completions/(basename $f)
end
```

**Atualizações posteriores** — uma vez nomeado, o próprio Inspetor se atualiza:

```fish
oko-update
```

---

## Layout do arquivo central

```
[REDACTED]/
├── fish/
│   ├── functions/          # corpo doutrinário do Inspetor (oko + helpers)
│   ├── completions/        # tabulação assistida
│   └── README.md           # manual técnico interno
├── pkgs/
│   ├── manifest.yaml       # decreto vigente
│   ├── state.yaml          # livro de carimbos
│   └── migrations/         # arquivo histórico, NNNN_<slug>.yaml
├── installed-packages.md   # censo de bootstrap (gerou a 0001_initial)
├── CLAUDE.md               # instrução ao Comissário-Assistente
├── LICENSE.md              # diretiva legal (ver advertências)
└── README.md               # este documento
```

---

## Dependências externas reconhecidas

- `yq` (Mike Farah, Go)
- `paru` · `brew` · `pipx` · `npm` · `snap` · `uvx`

Ausência destes utensílios é causa de **detenção administrativa** do Inspetor. Reinstale e reapresente-se.

---

## Variáveis de Estado

| Variável     | Função                                                                                          |
|--------------|-------------------------------------------------------------------------------------------------|
| `OKO_HOME`   | Endereço alternativo do arquivo central. Default: `./pkgs/`.                                      |
| `OKO_CONFIG` | Endereço alternativo do runtime do operador. Default: `~/.oko/config.yaml`.                       |

## Runtime do operador — `~/.oko/config.yaml`

O Inspetor consulta este arquivo (fora do repo) pra saber **quais managers reconhece**, em **que ordem**, com **quais argumentos fixos**, e **se exigem `sudo`**. Semeado automaticamente por `oko-update` na primeira corrida. Schema:

```yaml
version: 1
package_managers:
  brew:
    command: brew
    args: []          # flags fixas que entram entre o binário e o subcomando
    priority: 1        # ordenação ascendente; ties resolvem por identifier alfabético
    sudoer: false      # se true, operação é prefixada com `sudo`
  uvx:
    command: uv
    args: []
    priority: 2
    sudoer: false
  # ... (pipx/npm/paru/snap análogos)
  snap:
    command: snap
    args: []
    priority: 6
    sudoer: true
```

Edite à vontade: novo manager (com `command`/`args`/`priority`/`sudoer`) é reconhecido na próxima invocação. **`oko check`, `oko resolve`, `oko owner`, `oko install`, `oko remove`, `oko upgrade`** todos lêem essa lista; nada está hard-coded.

## Migração das ferramentas anteriores

Este repo absorveu duas peças que viviam soltas no host. Após confirmar que `oko upgrade` e `oko system` funcionam, o operador pode podar as antigas:

```fish
# Antigo `upgrade` (fish function solta)
rm -f ~/.config/fish/functions/upgrade.fish

# Antigo `plaguedoctor` / `pd` (plugin OMF)
for f in ~/.config/fish/functions/__plaguedoctor_*.fish \
         ~/.config/fish/functions/plaguedoctor.fish \
         ~/.config/fish/functions/pd.fish
    rm -f $f
end
```

O repositório `~/Chronopolis/repos/plaguedoctor/` permanece — decida se arquiva ou descarta a critério do Departamento.

---

## Avisos finais

- O carimbo do Inspetor é **APPROVED** (verde), **REJECTED** (vermelho) ou **INSPECTED** (amarelo). Não existe carimbo cinza. Casos cinza são, por decreto, vermelhos.
- A migration `0001_initial` foi marcada como aplicada em modo **faked** — o território já refletia o decreto no momento da nomeação.
- A migration `0002_remove_act` foi arquivada post-facto. O motivo da deportação consta como `[REDACTED by ОТДЕЛ]`. Não pergunte.

---

```
Документы пожалуйста.
```
