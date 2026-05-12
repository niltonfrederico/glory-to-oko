function __oko_header --description 'Department of Operations and Control banner'
    set -l red (set_color -o red)
    set -l yellow (set_color yellow)
    set -l dim (set_color brblack)
    set -l reset (set_color normal)
    echo ""
    echo -e "$red╔══════════════════════════════════════════════════════════════╗$reset"
    echo -e "$red║$reset $yellow ОТДЕЛ ОПЕРАЦИЙ И КОНТРОЛЯ · ДОКУМЕНТЫ ПОЖАЛУЙСТА  $reset       $red║$reset"
    echo -e "$red║$reset $dim Departamento de Operações e Controle              $reset       $red║$reset"
    echo -e "$red╚══════════════════════════════════════════════════════════════╝$reset"
end
