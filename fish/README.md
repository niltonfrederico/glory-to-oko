# `oko` — Departamento de Operações e Controle

CLI fish para gerenciar pacotes do host de forma declarativa + histórica (Django-style migrations).

## Layout

```
fish/functions/
├── oko.fish                    # entry-point + dispatcher
├── __oko_header.fish           # banner do Departamento
├── __oko_say.fish              # printer temático (info/ok/warn/nope/hush/inspector)
├── __oko_stamp.fish            # carimbos APPROVED / REJECTED / INSPECTED
├── __oko_paths.fish            # resolve OKO_HOME (default: ../pkgs)
├── __oko_manifest.fish         # CRUD em manifest.yaml
├── __oko_state.fish            # CRUD em state.yaml
├── __oko_probe.fish            # available?/installed? por manager
├── __oko_resolve.fish          # prioridade brew > uvx > pipx > npm > paru > snap
├── __oko_owner.fish            # quem tem este pacote instalado?
├── __oko_do.fish               # executa install/remove num manager
├── __oko_install.fish          # comando install
├── __oko_remove.fish           # comando remove
├── __oko_check.fish            # comando check
├── __oko_makemigrations.fish   # comando mm (diff manifest × histórico)
└── __oko_migrate.fish          # comando mi (aplica pendentes)
```

## Estado persistido (em `../pkgs/`)

- `manifest.yaml` — estado declarativo atual (`install`/`remove` mexem aqui).
- `migrations/NNNN_<slug>.yaml` — histórico imutável de operações.
- `state.yaml` — quais migrations já foram aplicadas.

A `0001_initial.yaml` foi gerada a partir do `installed-packages.md` e marcada como `applied` em `state.yaml` (faked), porque o host já reflete esse estado.

## Como instalar

Linka as funções no fish (ajuste o caminho do projeto se mudou):

```fish
for f in ~/Chronopolis/control/garuda/fish/functions/*.fish
    ln -sf $f ~/.config/fish/functions/(basename $f)
end
```

Daí qualquer shell fish nova já tem `oko` disponível.

Pra desinstalar, é só remover os symlinks:

```fish
for f in ~/Chronopolis/control/garuda/fish/functions/__oko_*.fish ~/Chronopolis/control/garuda/fish/functions/oko.fish
    rm -f ~/.config/fish/functions/(basename $f)
end
```

## Variáveis de ambiente

- `OKO_HOME` — diretório com `manifest.yaml`/`state.yaml`/`migrations/`. Default: `/home/kuresto/Chronopolis/control/garuda/pkgs`.

## Comandos

| Comando             | Alias | O que faz                                                         |
|---------------------|-------|-------------------------------------------------------------------|
| `oko install <p…>`  | `i`   | Instala respeitando prioridade. Skipa silencioso se já instalado. |
| `oko remove <p…>`   | `r`   | Remove via owner detectado. Skipa silencioso se ausente.          |
| `oko check <p…>`    | `c`   | Inspeciona disponibilidade × instalação em todos os 6 managers.   |
| `oko makemigrations` | `mm` | Snapshota o diff `manifest × histórico` numa nova migration.      |
| `oko migrate`       | `mi`  | Aplica migrations pendentes (idempotente, falha silenciosa).      |

`install` e `remove` aceitam `--manager <nome>` pra forçar um gerenciador.

## Cadeia de prioridade

`brew → uvx → pipx → npm → paru → snap`

Tanto pra resolução de "qual manager instala isso" quanto pra detecção de "qual manager já tem isso".

## Dependências

- `yq` (Mike Farah, Go) — parse/edição de YAML. Já está em `brew leaves`.
- `paru`, `brew`, `pipx`, `npm`, `snap`, `uvx` — já instalados no host.
