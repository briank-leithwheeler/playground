#!/usr/bin/env bash

run_check() {
    local num="$1"
    local code_ref="$2"
    local cmd="$3"

    sudo bash -c "set -o pipefail; shopt -s nullglob; $cmd" > /dev/null 2>&1
    local code=$?

    if [ $code -eq 0 ]; then
        printf "[ PASS ] (#%d) - %s\n" "$num" "$code_ref"
    else
        printf "[ FAIL ] (#%d) - %s (Code: %d)\n" "$num" "$code_ref" "$code"
    fi
}

printf "\n%s\n\n" "1. Filesystem Kernel Modules"
run_check 1 "JR4.C.1.1.1.1" \
    "modprobe -n -v cramfs 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q cramfs"

run_check 2 "JR4.C.1.1.1.2" \
    "modprobe -n -v freevxfs 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q freevxfs"

run_check 3 "JR4.C.1.1.1.3" \
    "modprobe -n -v hfs 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q hfs"

run_check 4 "JR4.C.1.1.1.4" \
    "modprobe -n -v hfsplus 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q hfsplus"

run_check 5 "JR4.C.1.1.1.5" \
    "modprobe -n -v jffs2 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q jffs2"

run_check 6 "JR4.C.1.1.1.6" \
    "modprobe -n -v usb-storage 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q usb_storage"

printf "\n%s\n\n" "2. Partition and Mount Options"
run_check 7 "JR4.C.1.1.2.1.1" \
    "mountpoint -q /tmp"

run_check 8 "JR4.C.1.1.2.1.2" \
    "! mountpoint -q /tmp || findmnt -n -o OPTIONS --target /tmp | grep -qw nodev"

run_check 9 "JR4.C.1.1.2.1.3" \
    "! mountpoint -q /tmp || findmnt -n -o OPTIONS --target /tmp | grep -qw nosuid"

run_check 10 "JR4.C.1.1.2.1.4" \
    "! mountpoint -q /tmp || findmnt -n -o OPTIONS --target /tmp | grep -qw noexec"

run_check 11 "JR4.C.1.1.2.2.4" \
    "! mountpoint -q /dev/shm || findmnt -n -o OPTIONS --target /dev/shm | grep -qw noexec"

run_check 12 "JR4.C.1.1.2.3.1" \
    "! mountpoint -q /home || findmnt -n -o OPTIONS --target /home | grep -qw nodev"

run_check 13 "JR4.C.1.1.2.3.2" \
    "! mountpoint -q /home || findmnt -n -o OPTIONS --target /home | grep -qw nosuid"

run_check 14 "JR4.C.1.1.2.4.1" \
    "! mountpoint -q /var || findmnt -n -o OPTIONS --target /var | grep -qw nodev"

run_check 15 "JR4.C.1.1.2.4.2" \
    "! mountpoint -q /var || findmnt -n -o OPTIONS --target /var | grep -qw nosuid"

run_check 16 "JR4.C.1.1.2.5.1" \
    "! mountpoint -q /var/tmp || findmnt -n -o OPTIONS --target /var/tmp | grep -qw nodev"

run_check 17 "JR4.C.1.1.2.5.2" \
    "! mountpoint -q /var/tmp || findmnt -n -o OPTIONS --target /var/tmp | grep -qw nosuid"

run_check 18 "JR4.C.1.1.2.5.3" \
    "! mountpoint -q /var/tmp || findmnt -n -o OPTIONS --target /var/tmp | grep -qw noexec"

run_check 19 "JR4.C.1.1.2.6.1" \
    "! mountpoint -q /var/log || findmnt -n -o OPTIONS --target /var/log | grep -qw nodev"

run_check 20 "JR4.C.1.1.2.6.2" \
    "! mountpoint -q /var/log || findmnt -n -o OPTIONS --target /var/log | grep -qw nosuid"

run_check 21 "JR4.C.1.1.2.6.3" \
    "! mountpoint -q /var/log || findmnt -n -o OPTIONS --target /var/log | grep -qw noexec"

run_check 22 "JR4.C.1.1.2.7.1" \
    "! mountpoint -q /var/log/audit || findmnt -n -o OPTIONS --target /var/log/audit | grep -qw nodev"

run_check 23 "JR4.C.1.1.2.7.2" \
    "! mountpoint -q /var/log/audit || findmnt -n -o OPTIONS --target /var/log/audit | grep -qw nosuid"

run_check 24 "JR4.C.1.1.2.7.3" \
    "! mountpoint -q /var/log/audit || findmnt -n -o OPTIONS --target /var/log/audit | grep -qw noexec"

printf "\n%s\n\n" "3. AppArmor, Bootloader, and Process Hardening"
run_check 25 "JR4.C.1.2.1.2" \
    "cat /sys/module/apparmor/parameters/enabled 2>/dev/null | grep -q '^Y$' && files=(/etc/default/grub /boot/grub/grub.cfg /boot/grub2/grub.cfg); [ \${#files[@]} -gt 0 ] && grep -REq '\\bapparmor=1\\b' \"\${files[@]}\" && grep -REq '\\bsecurity=apparmor\\b' \"\${files[@]}\""

run_check 26 "JR4.C.1.2.1.3" \
    "command -v aa-status >/dev/null 2>&1 && ! aa-status 2>/dev/null | grep -q 'processes are unconfined but have a profile defined'"

run_check 27 "JR4.C.1.3.1" \
    "files=(/boot/grub/grub.cfg /boot/grub2/grub.cfg /boot/grub/user.cfg /boot/grub2/user.cfg); [ \${#files[@]} -gt 0 ] && grep -REq '(^\\s*set\\s+superusers=|^\\s*password_pbkdf2\\s+)' \"\${files[@]}\""

run_check 28 "JR4.C.1.3.2" \
    "cfg=\$(ls /boot/grub/grub.cfg /boot/grub2/grub.cfg 2>/dev/null | head -n1); [ -n \"\$cfg\" ] && [ \"\$(stat -c '%U:%G' \"\$cfg\")\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' \"\$cfg\"))) -le 384 ]"

run_check 29 "JR4.C.1.4.1" \
    "sysctl -n kernel.randomize_va_space 2>/dev/null | grep -qx '2'"

run_check 30 "JR4.C.1.4.2" \
    "sysctl -n kernel.yama.ptrace_scope 2>/dev/null | grep -qx '1'"

run_check 31 "JR4.C.1.4.3" \
    "sysctl -n fs.suid_dumpable 2>/dev/null | grep -qx '0' && grep -REq '^\*\s+hard\s+core\s+0\b' /etc/security/limits.conf /etc/security/limits.d/*.conf 2>/dev/null"

run_check 32 "JR4.C.1.4.4" \
    "! dpkg -s prelink >/dev/null 2>&1"

run_check 33 "JR4.C.1.4.5" \
    "! grep -Eiq '^\s*enabled\s*=\s*1\b' /etc/default/apport 2>/dev/null"

printf "\n%s\n\n" "4. Banners and Access Controls"
run_check 34 "JR4.C.1.5.1" \
    "! grep -Eqs '(\\v|\\r|\\m|\\s)' /etc/motd 2>/dev/null"

run_check 35 "JR4.C.1.5.2" \
    "! grep -Eqs '(\\v|\\r|\\m|\\s)' /etc/issue 2>/dev/null"

run_check 36 "JR4.C.1.5.3" \
    "! grep -Eqs '(\\v|\\r|\\m|\\s)' /etc/issue.net 2>/dev/null"

run_check 37 "JR4.C.1.5.4" \
    "[ \"\$(stat -c '%U:%G' /etc/motd 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/motd 2>/dev/null))) -le 420 ]"

run_check 38 "JR4.C.1.5.5" \
    "[ \"\$(stat -c '%U:%G' /etc/issue 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/issue 2>/dev/null))) -le 420 ]"

run_check 39 "JR4.C.1.5.6" \
    "[ \"\$(stat -c '%U:%G' /etc/issue.net 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/issue.net 2>/dev/null))) -le 420 ]"

run_check 40 "JR4.C.2.1.13" \
    "! systemctl is-enabled rsync 2>/dev/null | grep -q enabled && ! systemctl is-active rsync 2>/dev/null | grep -q active && ! ss -lntu 2>/dev/null | grep -q ':873\\b'"

run_check 41 "JR4.C.2.1.18" \
    "! systemctl is-enabled apache2 2>/dev/null | grep -q enabled && ! systemctl is-active apache2 2>/dev/null | grep -q active && ! systemctl is-enabled nginx 2>/dev/null | grep -q enabled && ! systemctl is-active nginx 2>/dev/null | grep -q active && ! ss -lntu 2>/dev/null | grep -Eq ':(80|443)\\b'"

run_check 42 "JR4.C.2.2.4" \
    "! dpkg -s telnet >/dev/null 2>&1"

run_check 43 "JR4.C.2.2.6" \
    "! dpkg -s ftp >/dev/null 2>&1"

printf "\n%s\n\n" "5. Scheduled Tasks and Permissions"
run_check 44 "JR4.C.2.4.1.2" \
    "[ \"\$(stat -c '%U:%G' /etc/crontab 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/crontab 2>/dev/null))) -le 384 ]"

run_check 45 "JR4.C.2.4.1.3" \
    "[ \"\$(stat -c '%U:%G' /etc/cron.hourly 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/cron.hourly 2>/dev/null))) -le 448 ]"

run_check 46 "JR4.C.2.4.1.4" \
    "[ \"\$(stat -c '%U:%G' /etc/cron.daily 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/cron.daily 2>/dev/null))) -le 448 ]"

run_check 47 "JR4.C.2.4.1.5" \
    "[ \"\$(stat -c '%U:%G' /etc/cron.weekly 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/cron.weekly 2>/dev/null))) -le 448 ]"

run_check 48 "JR4.C.2.4.1.6" \
    "[ \"\$(stat -c '%U:%G' /etc/cron.monthly 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/cron.monthly 2>/dev/null))) -le 448 ]"

run_check 49 "JR4.C.2.4.1.7" \
    "[ \"\$(stat -c '%U:%G' /etc/cron.d 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/cron.d 2>/dev/null))) -le 448 ]"

run_check 50 "JR4.C.2.4.1.8" \
    "[ -f /etc/cron.allow ] && [ ! -f /etc/cron.deny ] && [ \"\$(stat -c '%U:%G' /etc/cron.allow 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/cron.allow 2>/dev/null))) -le 416 ]"

run_check 51 "JR4.C.2.4.2.1" \
    "[ -f /etc/at.allow ] && [ ! -f /etc/at.deny ] && [ \"\$(stat -c '%U:%G' /etc/at.allow 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/at.allow 2>/dev/null))) -le 416 ]"

printf "\n%s\n\n" "6. Network Configuration"
run_check 52 "JR4.C.3.1.1" \
    "[ -z \"\$(find /sys/class/net -mindepth 2 -maxdepth 2 -name wireless 2>/dev/null)\" ]"

run_check 53 "JR4.C.3.1.2" \
    "! systemctl is-enabled bluetooth 2>/dev/null | grep -q enabled && ! systemctl is-active bluetooth 2>/dev/null | grep -q active"

run_check 54 "JR4.C.3.2.1" \
    "sysctl -n net.ipv4.ip_forward 2>/dev/null | grep -qx '0' && (sysctl -n net.ipv6.conf.all.forwarding 2>/dev/null | grep -qx '0' || true)"

run_check 55 "JR4.C.3.2.10" \
    "sysctl -n net.ipv4.tcp_syncookies 2>/dev/null | grep -qx '1'"

run_check 56 "JR4.C.3.2.11" \
    "sysctl -n net.ipv6.conf.all.accept_ra 2>/dev/null | grep -qx '0' && sysctl -n net.ipv6.conf.default.accept_ra 2>/dev/null | grep -qx '0'"

run_check 57 "JR4.C.3.2.2" \
    "sysctl -n net.ipv4.conf.all.send_redirects 2>/dev/null | grep -qx '0' && sysctl -n net.ipv4.conf.default.send_redirects 2>/dev/null | grep -qx '0'"

run_check 58 "JR4.C.3.2.3" \
    "sysctl -n net.ipv4.icmp_ignore_bogus_error_responses 2>/dev/null | grep -qx '1'"

run_check 59 "JR4.C.3.2.4" \
    "sysctl -n net.ipv4.icmp_echo_ignore_broadcasts 2>/dev/null | grep -qx '1'"

run_check 60 "JR4.C.3.2.5" \
    "sysctl -n net.ipv4.conf.all.accept_redirects 2>/dev/null | grep -qx '0' && sysctl -n net.ipv4.conf.default.accept_redirects 2>/dev/null | grep -qx '0'"

run_check 61 "JR4.C.3.2.6" \
    "sysctl -n net.ipv4.conf.all.secure_redirects 2>/dev/null | grep -qx '0' && sysctl -n net.ipv4.conf.default.secure_redirects 2>/dev/null | grep -qx '0'"

run_check 62 "JR4.C.3.2.7" \
    "sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null | grep -Eq '^[12]$' && sysctl -n net.ipv4.conf.default.rp_filter 2>/dev/null | grep -Eq '^[12]$'"

run_check 63 "JR4.C.3.2.8" \
    "sysctl -n net.ipv4.conf.all.accept_source_route 2>/dev/null | grep -qx '0' && sysctl -n net.ipv4.conf.default.accept_source_route 2>/dev/null | grep -qx '0' && sysctl -n net.ipv6.conf.all.accept_source_route 2>/dev/null | grep -qx '0' && sysctl -n net.ipv6.conf.default.accept_source_route 2>/dev/null | grep -qx '0'"

run_check 64 "JR4.C.3.2.9" \
    "sysctl -n net.ipv4.conf.all.log_martians 2>/dev/null | grep -qx '1' && sysctl -n net.ipv4.conf.default.log_martians 2>/dev/null | grep -qx '1'"

run_check 65 "JR4.C.4.2.5" \
    "ufw status 2>/dev/null | grep -q 'Status: active' && ufw status numbered 2>/dev/null | grep -q '^\\['"

run_check 66 "JR4.C.4.2.6" \
    "ufw status verbose 2>/dev/null | grep -Eq 'Default:\s+deny \(incoming\)'"

printf "\n%s\n\n" "7. SSH and Privilege Escalation"
run_check 67 "JR4.C.5.1.1" \
    "[ \"\$(stat -c '%U:%G' /etc/ssh/sshd_config 2>/dev/null)\" = 'root:root' ] && [ \$((8#\$(stat -c '%a' /etc/ssh/sshd_config 2>/dev/null))) -le 384 ]"

run_check 68 "JR4.C.5.1.11" \
    "sshd -T 2>/dev/null | grep -Eq '^logingracetime\\s+[1-9][0-9]*$'"

run_check 69 "JR4.C.5.1.12" \
    "sshd -T 2>/dev/null | grep -Eq '^loglevel\\s+(VERBOSE|INFO)$'"

run_check 70 "JR4.C.5.1.14" \
    "sshd -T 2>/dev/null | awk '/^maxauthtries / {exit !(\$2<=4)} END {if (NR==0) exit 1}'"

run_check 71 "JR4.C.5.1.15" \
    "sshd -T 2>/dev/null | awk '/^maxsessions / {exit !(\$2<=10)} END {if (NR==0) exit 1}'"

run_check 72 "JR4.C.5.1.16" \
    "sshd -T 2>/dev/null | grep -Eq '^maxstartups\\s+([0-9]+:[0-9]+:[0-9]+|[0-9]+)$'"

run_check 73 "JR4.C.5.1.18" \
    "sshd -T 2>/dev/null | grep -Eq '^permitrootlogin\\s+no$'"

run_check 74 "JR4.C.5.1.19" \
    "sshd -T 2>/dev/null | grep -Eq '^permituserenvironment\\s+no$'"

run_check 75 "JR4.C.5.1.4" \
    "sshd -T 2>/dev/null | grep -Eq '^(allowusers|allowgroups|denyusers|denygroups)\\s+'"

run_check 76 "JR4.C.5.1.5" \
    "banner=\$(sshd -T 2>/dev/null | awk '/^banner / {print \$2}'); [ -n \"\$banner\" ] && [ \"\$banner\" != 'none' ] && [ -f \"\$banner\" ]"

run_check 77 "JR4.C.5.1.6" \
    "sshd -T 2>/dev/null | grep -Eq '^ciphers\\s+.+'"

run_check 78 "JR4.C.5.1.7" \
    "sshd -T 2>/dev/null | grep -Eq '^clientaliveinterval\\s+[1-9][0-9]*$' && sshd -T 2>/dev/null | awk '/^clientalivecountmax / {exit !(\$2<=3)} END {if (NR==0) exit 1}'"

run_check 79 "JR4.C.5.1.8" \
    "sshd -T 2>/dev/null | grep -Eq '^hostbasedauthentication\\s+no$'"

run_check 80 "JR4.C.5.1.9" \
    "sshd -T 2>/dev/null | grep -Eq '^ignorerhosts\\s+yes$'"

run_check 81 "JR4.C.5.2.3" \
    "files=(/etc/sudoers /etc/sudoers.d/*); [ \${#files[@]} -gt 0 ] && grep -RIEq '^\\s*Defaults\\s+.*logfile=' \"\${files[@]}\""

run_check 82 "JR4.C.5.2.4" \
    "files=(/etc/sudoers /etc/sudoers.d/*); [ \${#files[@]} -eq 0 ] || ! grep -RIEq '^\\s*Defaults\\s+.*!authenticate' \"\${files[@]}\""

run_check 83 "JR4.C.5.2.5" \
    "files=(/etc/sudoers /etc/sudoers.d/*); [ \${#files[@]} -gt 0 ] && grep -RIEh '^\\s*Defaults\\s+.*timestamp_timeout=' \"\${files[@]}\" | tail -n1 | awk -F= '{gsub(/[^0-9-]/,\"\",\$2); exit !(\$2>=0 && \$2<=15)}'"

run_check 84 "JR4.C.5.2.6" \
    "grep -Eq '^\\s*auth\\s+required\\s+pam_wheel.so.*use_uid' /etc/pam.d/su 2>/dev/null"

printf "\n%s\n\n" "8. PAM and Password Policy"
run_check 85 "JR4.C.5.3.1.3" \
    "dpkg -s libpam-pwquality >/dev/null 2>&1"

run_check 86 "JR4.C.5.3.2.2" \
    "grep -Eq '^\\s*auth\\s+.*pam_faillock.so' /etc/pam.d/common-auth 2>/dev/null && grep -Eq '^\\s*account\\s+.*pam_faillock.so' /etc/pam.d/common-account 2>/dev/null"

run_check 87 "JR4.C.5.3.2.3" \
    "grep -Eq '^\\s*password\\s+.*pam_pwquality.so' /etc/pam.d/common-password 2>/dev/null"

run_check 88 "JR4.C.5.3.2.4" \
    "grep -Eq '^\\s*password\\s+.*pam_pwhistory.so' /etc/pam.d/common-password 2>/dev/null"

run_check 89 "JR4.C.5.3.3.1.1" \
    "files=(/etc/security/faillock.conf /etc/security/faillock.conf.d/*.conf /etc/pam.d/common-auth); [ \${#files[@]} -gt 0 ] && grep -REh 'deny\\s*=\\s*[0-9]+' \"\${files[@]}\" | tail -n1 | awk -F= '{gsub(/[^0-9]/,\"\",\$2); exit !(\$2>0 && \$2<=5)}'"

run_check 90 "JR4.C.5.3.3.1.2" \
    "files=(/etc/security/faillock.conf /etc/security/faillock.conf.d/*.conf /etc/pam.d/common-auth); [ \${#files[@]} -gt 0 ] && grep -REq 'unlock_time\\s*=\\s*[0-9]+' \"\${files[@]}\""

run_check 91 "JR4.C.5.3.3.2.1" \
    "files=(/etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*difok\\s*=\\s*[2-9][0-9]*' \"\${files[@]}\""

run_check 92 "JR4.C.5.3.3.2.2" \
    "files=(/etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf); [ \${#files[@]} -gt 0 ] && grep -REh '^\\s*minlen\\s*=\\s*[0-9]+' \"\${files[@]}\" | tail -n1 | awk -F= '{gsub(/[^0-9]/,\"\",\$2); exit !(\$2>=14)}'"

run_check 93 "JR4.C.5.3.3.2.3" \
    "files=(/etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*maxrepeat\\s*=\\s*[0-9]+' \"\${files[@]}\""

run_check 94 "JR4.C.5.3.3.2.4" \
    "files=(/etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*maxsequence\\s*=\\s*[0-9]+' \"\${files[@]}\""

run_check 95 "JR4.C.5.3.3.2.5" \
    "files=(/etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf); [ \${#files[@]} -eq 0 ] || ! grep -REq '^\\s*dictcheck\\s*=\\s*0\\b' \"\${files[@]}\""

run_check 96 "JR4.C.5.3.3.2.6" \
    "files=(/etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf); [ \${#files[@]} -eq 0 ] || ! grep -REq '^\\s*enforcing\\s*=\\s*0\\b' \"\${files[@]}\""

run_check 97 "JR4.C.5.3.3.2.7" \
    "files=(/etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf /etc/pam.d/common-password); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*enforce_for_root\\b' \"\${files[@]}\""

run_check 98 "JR4.C.5.3.3.3.1" \
    "files=(/etc/security/pwhistory.conf /etc/security/pwhistory.conf.d/*.conf /etc/pam.d/common-password); [ \${#files[@]} -gt 0 ] && grep -REh 'remember\\s*=\\s*[0-9]+' \"\${files[@]}\" | tail -n1 | awk -F= '{gsub(/[^0-9]/,\"\",\$2); exit !(\$2>=24)}'"

run_check 99 "JR4.C.5.3.3.3.2" \
    "files=(/etc/security/pwhistory.conf /etc/security/pwhistory.conf.d/*.conf /etc/pam.d/common-password); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*enforce_for_root\\b' \"\${files[@]}\""

run_check 100 "JR4.C.5.3.3.3.3" \
    "grep -Eq '^\\s*password\\s+.*pam_pwhistory.so.*use_authtok' /etc/pam.d/common-password 2>/dev/null"

run_check 101 "JR4.C.5.3.3.4.1" \
    "! grep -Eq '^\\s*password\\s+.*pam_unix.so.*\\bnullok\\b' /etc/pam.d/common-password 2>/dev/null"

run_check 102 "JR4.C.5.3.3.4.2" \
    "! grep -Eq '^\\s*password\\s+.*pam_unix.so.*\\bremember\\b' /etc/pam.d/common-password 2>/dev/null"

run_check 103 "JR4.C.5.4.1.1" \
    "awk '/^PASS_MAX_DAYS/ {exit !(\$2>0 && \$2<=365)} END {if (NR==0) exit 1}' /etc/login.defs 2>/dev/null"

run_check 104 "JR4.C.5.4.1.2" \
    "awk '/^PASS_WARN_AGE/ {exit !(\$2>=7)} END {if (NR==0) exit 1}' /etc/login.defs 2>/dev/null"

run_check 105 "JR4.C.5.4.1.4" \
    "useradd -D 2>/dev/null | awk -F= '/^INACTIVE=/ {exit !(\$2>=0 && \$2<=45)} END {if (NR==0) exit 1}'"

run_check 106 "JR4.C.5.4.2.6" \
    "files=(/root/.bash_profile /root/.profile /etc/profile /etc/bash.bashrc /etc/login.defs); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*umask\\s+(027|077)\\b|^\\s*UMASK\\s+(027|077)\\b' \"\${files[@]}\""

run_check 107 "JR4.C.5.4.3.1" \
    "grep -REq '^\\s*TMOUT\\s*=\\s*[1-9][0-9]{0,2}\\b|^\\s*typeset\\s+-xr\\s+TMOUT\\s*=\\s*[1-9][0-9]{0,2}\\b' /etc/profile /etc/profile.d/*.sh /etc/bash.bashrc 2>/dev/null"

run_check 108 "JR4.C.5.4.3.2" \
    "files=(/etc/profile /etc/profile.d/*.sh /etc/bash.bashrc /etc/login.defs); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*umask\\s+(027|077)\\b|^\\s*UMASK\\s+(027|077)\\b' \"\${files[@]}\""

printf "\n%s\n\n" "9. Logging and Integrity"
run_check 109 "JR4.C.6.1.2.1.1" \
    "dpkg -s systemd-journal-remote >/dev/null 2>&1"

run_check 110 "JR4.C.6.1.2.1.2" \
    "systemctl is-enabled systemd-journal-upload 2>/dev/null | grep -q enabled && systemctl is-active systemd-journal-upload 2>/dev/null | grep -q active"

run_check 111 "JR4.C.6.1.2.1.3" \
    "! systemctl is-enabled systemd-journal-remote 2>/dev/null | grep -q enabled && ! systemctl is-active systemd-journal-remote 2>/dev/null | grep -q active"

run_check 112 "JR4.C.6.1.2.2" \
    "files=(/etc/systemd/journald.conf /etc/systemd/journald.conf.d/*.conf); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*Compress\\s*=\\s*yes\\b' \"\${files[@]}\""

run_check 113 "JR4.C.6.1.2.3" \
    "files=(/etc/systemd/journald.conf /etc/systemd/journald.conf.d/*.conf); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*Storage\\s*=\\s*persistent\\b' \"\${files[@]}\""

run_check 114 "JR4.C.6.1.3.3" \
    "files=(/etc/systemd/journald.conf /etc/systemd/journald.conf.d/*.conf); [ \${#files[@]} -gt 0 ] && grep -REq '^\\s*ForwardToSyslog\\s*=\\s*yes\\b' \"\${files[@]}\""

run_check 115 "JR4.C.6.1.4.1" \
    "! find /var/log -type f -perm /002 -print -quit 2>/dev/null | grep -q ."

run_check 116 "JR4.C.6.2.1" \
    "dpkg -s aide >/dev/null 2>&1 || dpkg -s aide-common >/dev/null 2>&1"

run_check 117 "JR4.C.6.2.2" \
    "systemctl is-enabled aidecheck.service 2>/dev/null | grep -q enabled || systemctl is-enabled aidecheck.timer 2>/dev/null | grep -q enabled || grep -REq '\\baide(\\.wrapper)?\\s+--check\\b' /etc/cron.* /etc/crontab 2>/dev/null"


