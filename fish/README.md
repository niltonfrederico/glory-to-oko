# `oko` — Departamento de Operações e Controle

CLI fish para gerenciar pacotes do host de forma declarativa + histórica (Django-style migrations).

## Layout

```
fish/functions/
├── oko.fish                          # entry-point + dispatcher
├── __oko_header.fish                 # banner do Departamento
├── __oko_say.fish                    # printer user-facing (stdout)
├── __oko_log.fish                    # logger diagnóstico estruturado (stderr; [ЖУРНАЛ])
├── __oko_stamp.fish                  # carimbos APPROVED / REJECTED / INSPECTED
├── __oko_paths.fish                  # resolve OKO_HOME (default: ../pkgs)
├── __oko_config_path.fish            # resolve OKO_CONFIG (default: ~/.oko/config.yaml)
├── __oko_config.fish                 # leitura do config (managers/command/args/sudoer)
├── __oko_config_init.fish            # seed do config default (idempotente)
├── __oko_manifest.fish               # CRUD em manifest.yaml
├── __oko_state.fish                  # CRUD em state.yaml
├── __oko_probe.fish                  # available?/installed? por manager
├── __oko_resolve.fish                # acha manager via config priority
├── __oko_owner.fish                  # quem tem este pacote instalado?
├── __oko_do.fish                     # executa install/remove num manager
├── __oko_install.fish                # comando install
├── __oko_remove.fish                 # comando remove
├── __oko_check.fish                  # comando check
├── __oko_upgrade.fish                # comando upgrade (+ migration audit)
├── __oko_system.fish                 # comando system (snapshot do host)
├── __oko_system_usage.fish           # help do system
├── __oko_system_dispatch_format.fish # roteador de formatadores
├── __oko_system_collect_*.fish       # 14 coletores (hardware/os/gui/...)
├── __oko_system_format_*.fish        # 4 formatadores (terminal/json/yaml/csv)
├── __oko_system_apps_group.fish      # helper agregador do collector apps
├── __oko_system_containers_runtime.fish  # helper docker/podman
├── __oko_json_kv.fish                # builder de objeto JSON flat
├── __oko_run.fish                    # runner com redireção opcional pra --log
├── __oko_spinner_start.fish          # spinner stderr
├── __oko_spinner_stop.fish           # idem
├── __oko_makemigrations.fish         # comando mm (diff manifest × histórico)
├── __oko_migration_write.fish        # writer de migrations (install/remove/upgrade)
└── __oko_migrate.fish                # comando mi (aplica pendentes)
```

## Estado persistido (em `../pkgs/`)

- `manifest.yaml` — estado declarativo atual (`install`/`remove` mexem aqui).
- `migrations/NNNN_<slug>.yaml` — histórico imutável de operações.
- `state.yaml` — quais migrations já foram aplicadas.

A `0001_initial.yaml` foi gerada a partir do `installed-packages.md` e marcada como `applied` em `state.yaml` (faked), porque o host já reflete esse estado.

## Como instalar

**Primeira vez** — linka as funções e completions na unha (ajuste o caminho se o projeto mudou):

```fish
for f in <repo>/fish/functions/*.fish
    ln -sf $f ~/.config/fish/functions/(basename $f)
end
for f in <repo>/fish/completions/*.fish
    ln -sf $f ~/.config/fish/completions/(basename $f)
end
```

**Atualizações subsequentes** — depois que `oko-update` está no PATH:

```fish
oko-update
```

Resincroniza tudo (functions + completions) a partir deste repo. Idempotente.

Pra desinstalar, é só remover os symlinks:

```fish
for f in <repo>/fish/functions/__oko_*.fish <repo>/fish/functions/oko.fish <repo>/fish/functions/oko-update.fish
    rm -f ~/.config/fish/functions/(basename $f)
end
rm -f ~/.config/fish/completions/oko.fish
```

## Variáveis de ambiente

- `OKO_HOME` — diretório com `manifest.yaml`/`state.yaml`/`migrations/`. Default: derivado da localização das funções (`<repo>/pkgs`).
- `OKO_CONFIG` — path do runtime do operador. Default: `~/.oko/config.yaml` (semeado por `oko-update`).

## Comandos

| Comando              | Alias | O que faz                                                          |
|----------------------|-------|--------------------------------------------------------------------|
| `oko install <p…>`   | `i`   | Instala respeitando prioridade. Skipa silencioso se já instalado.  |
| `oko remove <p…>`    | `r`   | Remove via owner detectado. Skipa silencioso se ausente.           |
| `oko check <p…>`     | `c`   | Inspeciona disponibilidade × instalação em todos os managers.      |
| `oko upgrade`        | `u`   | Atualiza managers em ordem. Aceita `--manager X` ou `--dry-run`.   |
| `oko system [flags]` | `s`   | Snapshot do host (apps/hardware/OS/...) em terminal/JSON/YAML/CSV. |
| `oko makemigrations` | `mm`  | Snapshota o diff `manifest × histórico` numa nova migration.       |
| `oko migrate`        | `mi`  | Aplica migrations pendentes (idempotente, falha silenciosa).       |

`install`, `remove` e `upgrade` aceitam `--manager <nome>` pra forçar um gerenciador.

`oko system` espelha o antigo `pd info system`: flags `-A/--ai` (JSON LLM-friendly), `-S/--no-sudo`, `-o/--output {json,yaml,csv}` e os 14 filtros de categoria (`-H/--hardware`, `-O/--os`, `-g/--gui`, `-t/--terminal`, `-a/--apps`, `--storage`, `--services`, `--pkg`, `--boot`, `--network`, `--security`, `--containers`, `--locale`, `--theming`).

## Cadeia de prioridade

A lista e a ordem vivem em `~/.oko/config.yaml`. Os 6 managers default são, em ordem: `brew → uvx → pipx → npm → paru → snap`. Mude `priority` no config pra reordenar; nada é hard-coded no código.

## Auditoria de upgrade

`oko upgrade` redige uma migration `NNNN_upgrade.yaml` com `action: upgrade` e a lista de managers tocados (ok + contagem de pacotes). `oko migrate` reconhece esse tipo: marca aplicada sem replay (versões não são retroativamente reproduzíveis).

`--detailed` (captura de versões pré/pós por pacote) está no schema do plano mas ainda **não está implementado** — a flag não existe. Modo coarse (contagem de pacotes pós-upgrade) é o que sai hoje.

## Dependências

- `yq` (Mike Farah, Go) — parse/edição de YAML.
- `jq` — manipulação JSON (collectors do `oko system`).
- Qualquer manager declarado em `~/.oko/config.yaml` que ainda não esteja instalado é detectado e silenciosamente pulado (sem erro).
