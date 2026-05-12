function oko --description 'Departamento de Operações e Controle — package migrations CLI'
    if test (count $argv) -eq 0
        __oko_header
        __oko_help
        return 0
    end

    set -l cmd $argv[1]
    set -l rest $argv[2..]

    switch $cmd
        case install i
            __oko_header
            __oko_install $rest
        case remove r
            __oko_header
            __oko_remove $rest
        case check c
            __oko_header
            __oko_check $rest
        case makemigrations mm
            __oko_header
            __oko_makemigrations $rest
        case migrate mi
            __oko_header
            __oko_migrate $rest
        case help -h --help
            __oko_header
            __oko_help
        case '*'
            __oko_header
            __oko_say nope "Comando desconhecido: $cmd"
            __oko_help
            return 1
    end
end

function __oko_help --description 'Show oko usage'
    set -l y (set_color yellow)
    set -l d (set_color brblack)
    set -l r (set_color normal)
    echo
    echo "  $y""Procedimentos autorizados:$r"
    echo
    echo "    oko install   (i)   <pkg…>    $d→ admitir indivíduos pela fronteira$r"
    echo "    oko remove    (r)   <pkg…>    $d→ deportar indivíduos$r"
    echo "    oko check     (c)   <pkg…>    $d→ inspecionar documentos$r"
    echo "    oko makemigrations (mm)       $d→ arquivar diff manifest×histórico$r"
    echo "    oko migrate   (mi)            $d→ aplicar migrations pendentes$r"
    echo
    echo "  $y""Cadeia de prioridade:$r brew → uvx → pipx → npm → paru → snap"
    echo "  $y""Lar do registro:$r       "(__oko_paths home)
    echo
    echo "  $d""Документы пожалуйста.$r"
    echo
end
