function __oko_check --description 'Inspect a package across all known managers'
    if test (count $argv) -eq 0
        __oko_say nope "Inspetor exige nome do indivíduo, camarada."
        return 1
    end

    set -l yellow (set_color yellow)
    set -l green (set_color green)
    set -l red (set_color red)
    set -l dim (set_color brblack)
    set -l reset (set_color normal)

    for pkg in $argv
        __oko_say inspector "Verificando documento: $yellow$pkg$reset"
        printf "  %-10s %-12s %-12s\n" MANAGER AVAILABLE INSTALLED
        printf "  %-10s %-12s %-12s\n" ───────── ───────── ─────────
        set -l first_available ""
        for m in brew uvx pipx npm paru snap
            set -l av "-"; set -l ic "-"
            if __oko_probe available $m $pkg
                set av "$green ✔$reset"
                if test -z "$first_available"
                    set first_available $m
                end
            else
                set av "$dim ✘$reset"
            end
            if __oko_probe installed $m $pkg
                set ic "$green ✔$reset"
            else
                set ic "$dim ✘$reset"
            end
            printf "  %-10s %-22s %-22s\n" $m $av $ic
        end
        echo
        if test -n "$first_available"
            __oko_stamp inspected "$pkg → recomendado via $first_available"
        else
            __oko_stamp rejected "$pkg não consta em nenhum registro"
        end
        echo
    end
end
