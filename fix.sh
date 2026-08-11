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

# 7- 24

sudo bash -c 'cp /etc/fstab /etc/fstab.bak && \
sed -i "/\/tmp/d; /\/var\/tmp/d; /\/dev\/shm/d" /etc/fstab && \
cat <<EOF >> /etc/fstab
tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec 0 0
tmpfs /var/tmp tmpfs defaults,nodev,nosuid,noexec 0 0
tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0
EOF
systemctl daemon-reload && \
mount -o remount,nodev,nosuid,noexec /tmp 2>/dev/null || mount /tmp
mount -o remount,nodev,nosuid,noexec /var/tmp 2>/dev/null || mount /var/tmp
mount -o remount,nodev,nosuid,noexec /dev/shm 2>/dev/null || mount /dev/shm
for mp in /home /var /var/log /var/log/audit; do
    findmnt "$mp" >/dev/null && mount -o remount,nodev,nosuid "$mp" 2>/dev/null
done'