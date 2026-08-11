#!/usr/bin/env bash

# Ensure administrative binaries are in PATH
export PATH="$PATH:/sbin:/usr/sbin:/usr/local/sbin"

# Function to execute check and print status
run_check() {
    local num="$1"
    local code_ref="$2"
    local cmd="$3"

    # Run command in a subshell with pipefail to catch pipe errors correctly
    bash -c "set -o pipefail; $cmd" > /dev/null 2>&1
    local code=$?

    if [ $code -eq 0 ]; then
        printf "[ PASS ] (#%d) - %s\n" "$num" "$code_ref"
    else
        printf "[ FAIL ] (#%d) - %s (Code: %d)\n" "$num" "$code_ref" "$code"
    fi
}

echo "=== Starting Security Compliance Verification ==="
echo ""

# ------------------------------------------------------------------------------
# 1. Filesystem Kernel Modules
# ------------------------------------------------------------------------------
run_check 1 "JR1.A.1.1" \
    "modprobe -n -v cramfs 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q cramfs"

run_check 2 "JR1.A.1.2" \
    "modprobe -n -v freevxfs 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q freevxfs"

run_check 3 "JR1.A.1.3" \
    "modprobe -n -v hfs 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q hfs"

run_check 4 "JR1.A.1.4" \
    "modprobe -n -v hfsplus 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q hfsplus"

run_check 5 "JR1.A.1.5" \
    "modprobe -n -v jffs2 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q jffs2"

run_check 6 "JR1.A.1.6" \
    "modprobe -n -v usb-storage 2>&1 | grep -E -q 'install /bin/(true|false)' && ! lsmod | grep -q usb-storage"

# ------------------------------------------------------------------------------
# 2. Filesystem Mount Options
# ------------------------------------------------------------------------------
run_check 7 "JR1.A.2.1" \
    "findmnt /tmp"

run_check 8 "JR1.A.2.2" \
    "findmnt -n /tmp | grep -q 'nodev'"

run_check 9 "JR1.A.2.3" \
    "findmnt -n /tmp | grep -q 'nosuid'"

run_check 10 "JR1.A.2.4" \
    "findmnt -n /tmp | grep -q 'noexec'"

run_check 11 "JR1.A.3.1" \
    "findmnt -n /dev/shm | grep -q 'noexec'"

run_check 12 "JR1.A.4.1" \
    "findmnt -n /home | grep -q 'nodev'"

run_check 13 "JR1.A.4.2" \
    "findmnt -n /home | grep -q 'nosuid'"

run_check 14 "JR1.A.5.1" \
    "findmnt -n /var | grep -q 'nodev'"

run_check 15 "JR1.A.5.2" \
    "findmnt -n /var | grep -q 'nosuid'"

run_check 16 "JR1.A.6.1" \
    "findmnt -n /var/tmp | grep -q 'nodev'"

run_check 17 "JR1.A.6.2" \
    "findmnt -n /var/tmp | grep -q 'nosuid'"

run_check 18 "JR1.A.6.3" \
    "findmnt -n /var/tmp | grep -q 'noexec'"

run_check 19 "JR1.A.7.1" \
    "findmnt -n /var/log | grep -q 'nodev'"

run_check 20 "JR1.A.7.2" \
    "findmnt -n /var/log | grep -q 'nosuid'"

run_check 21 "JR1.A.7.3" \
    "findmnt -n /var/log | grep -q 'noexec'"

run_check 22 "JR1.A.8.1" \
    "findmnt -n /var/log/audit | grep -q 'nodev'"

run_check 23 "JR1.A.8.2" \
    "findmnt -n /var/log/audit | grep -q 'nosuid'"

run_check 24 "JR1.A.8.3" \
    "findmnt -n /var/log/audit | grep -q 'noexec'"

# # ------------------------------------------------------------------------------
# # 3. AppArmor Configuration
# # ------------------------------------------------------------------------------
# run_check 25 "JR1.B.1.1" \
#     "true"

# run_check 26 "JR1.B.1.2" \
#     "true"

# # ------------------------------------------------------------------------------
# # 4. Bootloader Configuration
# # ------------------------------------------------------------------------------
# run_check 27 "JR1.C.1.1" \
#     "true"

# run_check 28 "JR1.C.1.2" \
#     "[ \$(stat -c '%a %U %G' /boot/grub/grub.cfg 2>/dev/null) = '600 root root' ]"

# # ------------------------------------------------------------------------------
# # 5. Process Hardening
# # ------------------------------------------------------------------------------
# run_check 29 "JR1.D.1.1" \
#     "[ \$(sysctl -n kernel.randomize_va_space) -eq 2 ]"

# run_check 30 "JR1.D.1.2" \
#     "[ \$(sysctl -n kernel.yama.ptrace_scope) -ge 1 ]"

# run_check 31 "JR1.D.1.3" \
#     "grep -E -q '^\*\s+hard\s+core\s+0' /etc/security/limits.conf /etc/security/limits.d/*"

# run_check 32 "JR1.D.1.4" \
#     "! command -v prelink"

# run_check 33 "JR1.D.1.5" \
#     "! systemctl is-active --quiet apport"

# # ------------------------------------------------------------------------------
# # 6. Warning Banners
# # ------------------------------------------------------------------------------
# run_check 34 "JR1.E.1.1" \
#     "[ -s /etc/motd ]"

# run_check 35 "JR1.E.1.2" \
#     "[ -s /etc/issue ]"

# run_check 36 "JR1.E.1.3" \
#     "[ -s /etc/issue.net ]"

# run_check 37 "JR1.E.1.4" \
#     "[ \$(stat -c '%a %U %G' /etc/motd 2>/dev/null) = '644 root root' ]"

# run_check 38 "JR1.E.1.5" \
#     "[ \$(stat -c '%a %U %G' /etc/issue 2>/dev/null) = '644 root root' ]"

# run_check 39 "JR1.E.1.6" \
#     "[ \$(stat -c '%a %U %G' /etc/issue.net 2>/dev/null) = '644 root root' ]"

# # ------------------------------------------------------------------------------
# # 7. Services (Server & Client)
# # ------------------------------------------------------------------------------
# run_check 40 "JR2.A.1.1" \
#     "! systemctl is-enabled --quiet rsync 2>/dev/null"

# run_check 41 "JR2.A.2.1" \
#     "true"

# run_check 42 "JR2.B.1.1" \
#     "true"

# run_check 43 "JR2.B.1.2" \
#     "! command -v ftp"

# # ------------------------------------------------------------------------------
# # 8. Cron & At Configuration
# # ------------------------------------------------------------------------------
# run_check 44 "JR2.C.1.1" \
#     "[ \$(stat -c '%a %U %G' /etc/crontab 2>/dev/null) = '600 root root' ]"

# run_check 45 "JR2.C.1.2" \
#     "[ \$(stat -c '%a %U %G' /etc/cron.hourly 2>/dev/null) = '700 root root' ]"

# run_check 46 "JR2.C.1.3" \
#     "[ \$(stat -c '%a %U %G' /etc/cron.daily 2>/dev/null) = '700 root root' ]"

# run_check 47 "JR2.C.1.4" \
#     "[ \$(stat -c '%a %U %G' /etc/cron.weekly 2>/dev/null) = '700 root root' ]"

# run_check 48 "JR2.C.1.5" \
#     "[ \$(stat -c '%a %U %G' /etc/cron.monthly 2>/dev/null) = '700 root root' ]"

# run_check 49 "JR2.C.1.6" \
#     "[ \$(stat -c '%a %U %G' /etc/cron.d 2>/dev/null) = '700 root root' ]"

# run_check 50 "JR2.C.1.7" \
#     "[ -f /etc/cron.allow ] && [ \$(stat -c '%a' /etc/cron.allow) = '640' ]"

# run_check 51 "JR2.C.2.1" \
#     "[ -f /etc/at.allow ] && [ \$(stat -c '%a' /etc/at.allow) = '640' ]"

# # ------------------------------------------------------------------------------
# # 9. Network Hardening & Sysctl Parameters
# # ------------------------------------------------------------------------------
# run_check 52 "JR3.A.1.1" \
#     "nmcli radio wifi 2>/dev/null | grep -q 'disabled' || [ \$(nmcli device 2>/dev/null | grep -c 'wifi') -eq 0 ]"

# run_check 53 "JR3.A.1.2" \
#     "! systemctl is-active --quiet bluetooth"

# run_check 54 "JR3.B.1.1" \
#     "[ \$(sysctl -n net.ipv4.ip_forward) -eq 0 ]"

# run_check 55 "JR3.B.1.2" \
#     "[ \$(sysctl -n net.ipv4.tcp_syncookies) -eq 1 ]"

# run_check 56 "JR3.B.1.3" \
#     "[ \$(sysctl -n net.ipv6.conf.all.accept_ra) -eq 0 ]"

# run_check 57 "JR3.B.1.4" \
#     "[ \$(sysctl -n net.ipv4.conf.all.send_redirects) -eq 0 ]"

# run_check 58 "JR3.B.1.5" \
#     "[ \$(sysctl -n net.ipv4.icmp_ignore_bogus_error_responses) -eq 1 ]"

# run_check 59 "JR3.B.1.6" \
#     "[ \$(sysctl -n net.ipv4.icmp_echo_ignore_broadcasts) -eq 1 ]"

# run_check 60 "JR3.B.1.7" \
#     "[ \$(sysctl -n net.ipv4.conf.all.accept_redirects) -eq 0 ]"

# run_check 61 "JR3.B.1.8" \
#     "[ \$(sysctl -n net.ipv4.conf.all.secure_redirects) -eq 0 ]"

# run_check 62 "JR3.B.1.9" \
#     "[ \$(sysctl -n net.ipv4.conf.all.rp_filter) -eq 1 ]"

# run_check 63 "JR3.B.1.10" \
#     "[ \$(sysctl -n net.ipv4.conf.all.accept_source_route) -eq 0 ]"

# run_check 64 "JR3.B.1.11" \
#     "[ \$(sysctl -n net.ipv4.conf.all.log_martians) -eq 1 ]"

# # ------------------------------------------------------------------------------
# # 10. Firewall Configuration
# # ------------------------------------------------------------------------------
# run_check 65 "JR3.C.1.1" \
#     "true"

# run_check 66 "JR3.C.1.2" \
#     "true"

# # ------------------------------------------------------------------------------
# # 11. SSH Server Configuration
# # ------------------------------------------------------------------------------
# run_check 67 "JR3.D.1.1" \
#     "[ \$(stat -c '%a %U %G' /etc/ssh/sshd_config 2>/dev/null) = '600 root root' ]"

# run_check 68 "JR3.D.1.2" \
#     "sshd -T 2>/dev/null | grep -E -q 'logingracetime ([1-9]|[1-5][0-9]|60)'"

# run_check 69 "JR3.D.1.3" \
#     "sshd -T 2>/dev/null | grep -E -q 'loglevel (INFO|VERBOSE)'"

# run_check 70 "JR3.D.1.4" \
#     "sshd -T 2>/dev/null | grep -E -q 'maxauthtries [1-4]'"

# run_check 71 "JR3.D.1.5" \
#     "sshd -T 2>/dev/null | grep -E -q 'maxsessions ([1-9]|10)'"

# run_check 72 "JR3.D.1.6" \
#     "sshd -T 2>/dev/null | grep -q 'maxstartups 10:30:60'"

# run_check 73 "JR3.D.1.7" \
#     "sshd -T 2>/dev/null | grep -q 'permitrootlogin no'"

# run_check 74 "JR3.D.1.8" \
#     "sshd -T 2>/dev/null | grep -q 'permituserenvironment no'"

# run_check 75 "JR3.D.1.9" \
#     "sshd -T 2>/dev/null | grep -E -q '(allowusers|allowgroups|denyusers|denygroups)'"

# run_check 76 "JR3.D.1.10" \
#     "sshd -T 2>/dev/null | grep -q 'banner /etc/issue.net'"

# run_check 77 "JR3.D.1.11" \
#     "sshd -T 2>/dev/null | grep -q 'ciphers'"

# run_check 78 "JR3.D.1.12" \
#     "sshd -T 2>/dev/null | grep -q 'clientaliveinterval [1-9]' && sshd -T 2>/dev/null | grep -q 'clientalivecountmax [1-9]'"

# run_check 79 "JR3.D.1.13" \
#     "sshd -T 2>/dev/null | grep -q 'hostbasedauthentication no'"

# run_check 80 "JR3.D.1.14" \
#     "sshd -T 2>/dev/null | grep -q 'ignorerhosts yes'"

# # ------------------------------------------------------------------------------
# # 12. Privilege Escalation & PAM Security
# # ------------------------------------------------------------------------------
# run_check 81 "JR4.A.1.1" \
#     "grep -r -E -q 'logfile=' /etc/sudoers /etc/sudoers.d/"

# run_check 82 "JR4.A.1.2" \
#     "! grep -r -E -q '!authenticate' /etc/sudoers /etc/sudoers.d/"

# run_check 83 "JR4.A.1.3" \
#     "grep -r -E -q 'timestamp_timeout=([0-9]|1[0-5])\b' /etc/sudoers /etc/sudoers.d/"

# run_check 84 "JR4.A.1.4" \
#     "grep -E -q 'auth\s+required\s+pam_wheel.so' /etc/pam.d/su"

# run_check 85 "JR4.A.2.1" \
#     "dpkg -s libpam-pwquality 2>/dev/null | grep -q 'Status: install ok installed'"

# run_check 86 "JR4.A.2.2" \
#     "grep -E -q 'pam_faillock.so' /etc/pam.d/common-auth"

# run_check 87 "JR4.A.2.3" \
#     "grep -E -q 'pam_pwquality.so' /etc/pam.d/common-password"

# run_check 88 "JR4.A.2.4" \
#     "grep -E -q 'pam_pwhistory.so.*remember=24' /etc/pam.d/common-password"

# run_check 89 "JR4.A.3.1" \
#     "grep -E -q 'deny\s*=\s*[1-5]\b' /etc/security/faillock.conf /etc/pam.d/common-auth"

# run_check 90 "JR4.A.3.2" \
#     "grep -E -q 'unlock_time\s*=\s*(0|[9][0][0]|1[0-9]{3})' /etc/security/faillock.conf /etc/pam.d/common-auth"

# run_check 91 "JR4.A.4.1" \
#     "grep -E -q 'difok\s*=\s*([2-9]|[1-9][0-9])' /etc/security/pwquality.conf"

# run_check 92 "JR4.A.4.2" \
#     "grep -E -q 'minlen\s*=\s*(1[4-9]|[2-9][0-9])' /etc/security/pwquality.conf"

# run_check 93 "JR4.A.4.3" \
#     "grep -E -q 'maxrepeat\s*=\s*[1-3]' /etc/security/pwquality.conf"

# run_check 94 "JR4.A.4.4" \
#     "grep -E -q 'maxsequence\s*=\s*[1-3]' /etc/security/pwquality.conf"

# run_check 95 "JR4.A.4.5" \
#     "! grep -E -q 'dictcheck\s*=\s*0' /etc/security/pwquality.conf"

# run_check 96 "JR4.A.4.6" \
#     "! grep -E -q 'enforcing\s*=\s*0' /etc/security/pwquality.conf"

# run_check 97 "JR4.A.4.7" \
#     "grep -E -q 'enforce_for_root' /etc/security/pwquality.conf /etc/pam.d/common-password"

# run_check 98 "JR4.A.5.1" \
#     "grep -E -q 'remember\s*=\s*(2[4-9]|[3-9][0-9])' /etc/pam.d/common-password"

# run_check 99 "JR4.A.5.2" \
#     "grep -E -q 'pam_pwhistory.so.*enforce_for_root' /etc/pam.d/common-password"

# run_check 100 "JR4.A.5.3" \
#     "grep -E -q 'pam_pwhistory.so.*use_authtok' /etc/pam.d/common-password"

# run_check 101 "JR4.A.6.1" \
#     "! grep -R -q 'nullok' /etc/pam.d/"

# run_check 102 "JR4.A.6.2" \
#     "! grep -E -q 'pam_unix.so.*remember' /etc/pam.d/"

# # ------------------------------------------------------------------------------
# # 13. User Accounts & Environment Settings
# # ------------------------------------------------------------------------------
# run_check 103 "JR4.B.1.1" \
#     "[ \$(grep -E '^PASS_MAX_DAYS' /etc/login.defs | awk '{print \$2}') -le 365 ]"

# run_check 104 "JR4.B.1.2" \
#     "[ \$(grep -E '^PASS_WARN_AGE' /etc/login.defs | awk '{print \$2}') -ge 7 ]"

# run_check 105 "JR4.B.1.3" \
#     "[ \$(useradd -D | grep INACTIVE | cut -d= -f2) -le 45 ]"

# run_check 106 "JR4.B.2.1" \
#     "grep -E -q 'umask 027|umask 0027' /root/.bashrc /root/.profile"

# run_check 107 "JR4.B.3.1" \
#     "grep -E -q 'TMOUT=(900|[1-8][0-9]{2}|[1-9][0-9]?)' /etc/profile /etc/profile.d/*.sh"

# run_check 108 "JR4.B.3.2" \
#     "grep -E -q 'UMASK\s+027' /etc/login.defs"

# # ------------------------------------------------------------------------------
# # 14. Remote Logging, Journald & Integrity Checking
# # ------------------------------------------------------------------------------
# run_check 109 "JR4.C.1.1" \
#     "true"

# run_check 110 "JR4.C.1.2" \
#     "true"

# run_check 111 "JR4.C.1.3" \
#     "true"

# run_check 112 "JR4.C.2.1" \
#     "grep -E -q '^Compress=yes' /etc/systemd/journald.conf"

# run_check 113 "JR4.C.2.2" \
#     "grep -E -q '^Storage=persistent' /etc/systemd/journald.conf"

# run_check 114 "JR4.C.3.1" \
#     "grep -E -q '^ForwardToSyslog=yes' /etc/systemd/journald.conf"

# run_check 115 "JR4.C.4.1" \
#     "find /var/log -type f -perm /027 | [ \$(wc -l) -eq 0 ]"

# run_check 116 "JR4.C.5.1" \
#     "true"

# run_check 117 "JR4.C.6.2.1" \
#     "[ ! -f /usr/bin/aide ] || [ -f /etc/cron.daily/aide ]"

# echo ""
# echo "=== Audit Finished ==="