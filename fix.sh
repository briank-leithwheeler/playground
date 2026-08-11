# 1 - 5

sudo bash -c '
for mod in cramfs freevxfs hfs hfsplus jffs2 ufs; do
    printf "install %s /bin/false\nblacklist %s\n" "$mod" "$mod" > /etc/modprobe.d/${mod}.conf
    rmmod "$mod" 2>/dev/null || true
done
depmod -a
update-initramfs -u
'

# 6
sudo bash -c 'cat <<EOF > /etc/modprobe.d/usb-storage.conf
install usb-storage /bin/true
blacklist usb-storage
EOF'

# 44
sudo bash -c '
if [ -f /etc/crontab ]; then
    chown root:root /etc/crontab
    chmod 600 /etc/crontab
fi
'

# 45 - 49
sudo bash -c '
for dir in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly /etc/cron.d; do
    mkdir -p "$dir"
    chown root:root "$dir"
    chmod 700 "$dir"
done
'

# 50
sudo bash -c '
rm -f /etc/cron.deny
touch /etc/cron.allow
chown root:root /etc/cron.allow
chmod 640 /etc/cron.allow
'

# 51
sudo bash -c '
rm -f /etc/at.deny
touch /etc/at.allow
chown root:root /etc/at.allow
chmod 640 /etc/at.allow
'

# 67
sudo bash -c '
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
'

# 68 - 80
sudo bash -c 'cat <<EOF > /etc/ssh/sshd_config.d/99-hardening.conf
LoginGraceTime 60
LogLevel INFO
MaxAuthTries 4
MaxSessions 10
MaxStartups 10:30:60
PermitRootLogin no
PermitUserEnvironment no
DenyUsers root
Banner /etc/issue.net
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
ClientAliveInterval 300
ClientAliveCountMax 3
HostbasedAuthentication no
IgnoreRhosts yes
EOF'

# 76
sudo bash -c '
touch /etc/issue.net
chown root:root /etc/issue.net
chmod 644 /etc/issue.net
'

# 81
sudo bash -c '
touch /var/log/sudo.log
chown root:root /var/log/sudo.log
chmod 600 /var/log/sudo.log
'

# 83
sudo bash -c 'cat <<EOF > /etc/sudoers.d/99-hardening
Defaults logfile="/var/log/sudo.log"
Defaults timestamp_timeout=15
EOF
chown root:root /etc/sudoers.d/99-hardening
chmod 440 /etc/sudoers.d/99-hardening'

# 84
sudo bash -c '
sed -i "/pam_wheel.so/d" /etc/pam.d/su
printf "auth required pam_wheel.so use_uid group=sudo\n" >> /etc/pam.d/su
'