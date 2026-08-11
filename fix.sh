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

# 44 - 51
sudo bash -c '
# 44 Ensure permissions on /etc/crontab are configured (root:root, 600 or more restrictive)
if [ -f /etc/crontab ]; then
    chown root:root /etc/crontab
    chmod 600 /etc/crontab
fi

# 45-49 Ensure cron directories are configured (root:root, 700 or more restrictive)
for dir in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly /etc/cron.d; do
    mkdir -p "$dir"
    chown root:root "$dir"
    chmod 700 "$dir"
done

# 50 Ensure crontab is restricted to authorized users
rm -f /etc/cron.deny
touch /etc/cron.allow
chown root:root /etc/cron.allow
chmod 640 /etc/cron.allow

# 51 Ensure at is restricted to authorized users
rm -f /etc/at.deny
touch /etc/at.allow
chown root:root /etc/at.allow
chmod 640 /etc/at.allow
'

