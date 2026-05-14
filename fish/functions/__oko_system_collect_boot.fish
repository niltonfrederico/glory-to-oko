function __oko_system_collect_boot --description 'Collect bootloader and kernel cmdline under .boot'
    set -l loader unknown
    if command -q bootctl; and bootctl is-installed >/dev/null 2>&1
        set loader systemd-boot
    else if test -d /boot/grub -o -f /etc/default/grub
        set loader grub
    end

    set -l cmdline ''
    if test -r /proc/cmdline
        set cmdline (string trim </proc/cmdline)
    end

    __oko_json_kv \
        loader "$loader" \
        kernel_cmdline "$cmdline" \
        | jq '{boot: .}'
end
