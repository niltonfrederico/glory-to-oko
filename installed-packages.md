# Pacotes instalados manualmente

Inventário do que o Nilton instalou por escolha própria neste host, separado por gerenciador. Não inclui dependências puxadas em cascata nem pacotes que vieram de fábrica com a ISO da Garuda.

Reconstruído a partir de `/var/log/pacman.log` (comandos `pacman -S` / `pacman --sync` e `paru -S`), de `brew leaves` e de `snap list`. Snapshot: 2026-05-12.

---

## paru (repos oficiais + Chaotic-AUR)

A maior parte veio do Chaotic-AUR (repo binário que a Garuda habilita por padrão); `paru` é só a fachada — o pacote em si pode ser do `core`/`extra`/`chaotic-aur`.

### Sistema / base

- **base-devel** — meta-grupo de compiladores e ferramentas (gcc, make, patch, fakeroot). Pré-requisito pra qualquer build de AUR.
- **performance-tweaks** — meta-pacote da Garuda com ajustes de IO scheduler, swappiness, etc.
- **garuda-mokka** — meta do tema Mokka (perfil KDE/Plasma usado no host).
- **garuda-toolbox** — coletânea de utilitários gráficos da Garuda.
- **rate-mirrors** — escolhe os mirrors mais rápidos do pacman.
- **fwupd** — daemon de firmware update (LVFS).
- **linux-headers** — headers do kernel; necessários pra DKMS.
- **v4l2loopback-dkms** — módulo de loopback de webcam (OBS virtual camera, etc.).

### Desktop / KDE

- **kwin-effect-rounded-corners-git** — efeito KWin com cantos arredondados.
- **kwin-effects-better-blur-dx** — efeito KWin de blur (usado pela Mokka).
- **ark** — gerenciador de arquivos compactados (KDE).
- **dolphin** — file manager do KDE.
- **kate** — editor de texto do KDE.
- **okular** — visualizador de PDF/documento do KDE.
- **partitionmanager** — particionador gráfico do KDE.
- **qdirstat** — análise visual de uso de disco.
- **ghostty** — terminal GPU-accelerated, default atual.
- **wayland-cedilla-fix** _(AUR)_ — corrige `ç` em apps Wayland que ignoram XCompose.
- **vicinae-bin** _(AUR)_ — launcher/Raycast-like para Linux.

### Input method (cedilha em apps Qt/GTK)

- **fcitx5** — framework de input method.
- **fcitx5-configtool**, **fcitx5-gtk**, **fcitx5-qt** — UI de config e integrações GTK/Qt.

### Browsers / comunicação

- **chromium** — Chromium (browser auxiliar pra debug e perfis isolados).
- **google-chrome** — Chrome (compat com sites que exigem Widevine/specifics).
- **discord** — Discord oficial.
- **slack-desktop** — Slack desktop.
- **proton-mail-bin** _(AUR)_ — cliente desktop oficial do Proton Mail.

### Editores / dev

- **visual-studio-code-bin** — VSCode build oficial (não-OSS); plataforma principal de dev.
- **lldb** — debugger LLVM (útil pra Rust/C++).
- **jdk-openjdk** — JDK OpenJDK (para projetos que precisam de Java).
- **ruby** — interpretador Ruby.
- **tectonic** — engine LaTeX moderno (XeTeX-based, autossuficiente).
- **graphviz** — renderização de grafos (`dot`).
- **gnuplot** — plotting CLI.
- **python-dbus**, **python-gobject** — bindings Python pra D-Bus e GObject (necessários por scripts que mexem em apps GTK/systemd).
- **bruno** — cliente HTTP/REST alternativo ao Postman/Insomnia (offline, git-friendly).
- **playwright** — automação de browser pra testes E2E.
- **xorg-xev** — utilitário pra inspecionar eventos de teclado/mouse (debug de keybinds).

### Container / virtualização

- **docker** — engine Docker.
- **docker-compose** — orquestração de containers via YAML.
- **docker-buildx** — builder multiplatform/BuildKit.
- **docker-rootless-extras** — suporte a Docker rootless.
- **slirp4netns**, **fuse-overlayfs** — backends de rede/storage do rootless Docker.
- **waydroid** — Android container nativo em Wayland.
- **waydroid-settings-git** _(AUR)_ — GUI de config do Waydroid.
- **lact** — controle de GPU AMD (clocks, fan curves).

### Aplicativos / mídia

- **spotify** — Spotify oficial.
- **vlc** — VLC.
- **mpv** — player de vídeo leve, scriptável.
- **obsidian** — knowledge base / notas em Markdown.
- **homebank** — finanças pessoais.
- **superproductivity-bin** — task tracker / pomodoro.
- **deluge-gtk** — cliente BitTorrent.
- **rpi-imager** — flasher de imagem pra Raspberry Pi e cartões SD.
- **bauh** — GUI multi-source pra gerenciar pacotes (snap/flatpak/AUR/appimage).
- **appimagepool-appimage** — loja/launcher de AppImages.

### Segurança / rede

- **opensnitch** — firewall application-level (interativo, à la Little Snitch).
- **nmap** — port scanner.
- **bluez-utils** — utilitários CLI de Bluetooth (`bluetoothctl`, etc.).

### Libs marcadas explicit

Pequenas — instaladas como dep direta de algo manual que precisou:

- **flite** — TTS leve (dep de algum cliente que invoca síntese de fala).
- **icu** — Unicode/locale.
- **libproxy** — descoberta de proxy.
- **libxml2** — parser XML.

### Sistema / outros

- **htop** — monitor de processos.
- **7zip** — compactador.
- **rsync** — sincronização.

### AUR (de fato, foreign)

Marcados acima com _(AUR)_. Resumo: `proton-mail-bin`, `snapd`, `vicinae-bin`, `waydroid-settings-git`, `wayland-cedilla-fix`.

---

## brew (Homebrew on Linux)

Pacotes top-level (`brew leaves`) — só o que foi pedido explicitamente, sem dependências.

### Dev CLIs / linguagens

- **rustup** — gerenciador de toolchain Rust.
- **python@3.13** — Python 3.13.
- **nvm** — gerenciador de versões do Node.
- **neovim** — editor.
- **tmux** — multiplexer de terminal.
- **gh** — CLI oficial do GitHub.
- **act** — roda GitHub Actions localmente.
- **shellcheck** — linter de shell scripts.
- **jq**, **yq** — query JSON / YAML.
- **miller** — query/transform de CSV/TSV/JSON (`mlr`).

### Kubernetes / cloud / infra

- **kubernetes-cli** — `kubectl`.
- **kubectx** — troca de contexto/namespace kubectl.
- **k9s** — TUI pra Kubernetes.
- **k3d** — k8s local em Docker (k3s-in-docker).
- **helm** — gerenciador de charts.
- **opentofu** — fork open-source do Terraform.
- **tflint** — linter de Terraform/OpenTofu.
- **oci-cli** — CLI Oracle Cloud.
- **caddy** — web server / reverse proxy com HTTPS automático.
- **nginx** — web server / reverse proxy clássico.
- **dnsmasq** — DNS/DHCP local.
- **docker-credential-helper** — store de credenciais Docker.
- **arp-scan** — varredura ARP de rede.

### AI / agentes

- **aider** — pair programming AI no terminal.
- **gemini-cli** — CLI do Google Gemini.

### Workflow / web

- **dagu** — scheduler de workflows.
- **hugo** — static site generator.

### Dados / texto

- **harlequin** — TUI SQL multi-engine.
- **dust** — `du` redesenhado.
- **ddgr** — busca DuckDuckGo CLI.
- **s-search** — busca web CLI.
- **uchardet** — detector de encoding.
- **qpdf** — manipulação de PDF.

### Mídia (ffmpeg stack)

- **ffmpeg** — codec/converter Swiss-army.
- **libass** — render de legendas (ASS/SSA).
- **libbluray** — leitura de Blu-ray.
- **libplacebo** — biblioteca de render de vídeo.
- **rubberband** — time-stretch/pitch-shift de áudio.
- **vapoursynth** — frame-server pra vídeo.
- **mujs** — engine JS embarcada (dep de mpv/ffmpeg config).
- **yt-dlp** — downloader yt e cia.

### X / sistema (esoteric)

- **libxfont2**, **xkeyboard-config** — necessários por algum build local de utilitário X.
- **libva**, **libvdpau**, **libclc**, **libarchive** — libs marcadas explicit porque foram pedidas no install de algo top-level.
- **pipx** — instalador de apps Python isolados.
- **commitlint** — lint de commit messages.

### Taps externos

- **steipete/tap/gogcli** — CLI de GOG.com (downloads/library).
- **yakitrak/yakitrak/obsidian-cli** — CLI de Obsidian.

---

## snap

Apenas dois apps de fato (Pieces); o resto são bases/runtimes que o snapd puxa pra rodar qualquer snap.

- **pieces-for-developers** — desktop app do Pieces (memória de snippets/AI).
- **pieces-os** — runtime/daemon do Pieces.

### Bases (instaladas como dep, listadas só pra registro)

- **bare** — base mínima.
- **core24** — runtime base do Snap (Ubuntu 24.04).
- **gnome-46-2404** — runtime GNOME pra snaps gráficos.
- **gtk-common-themes** — temas GTK pra snaps.
- **mesa-2404** — drivers Mesa pra snaps.
- **snapd** — o daemon em si (também presente como AUR).
