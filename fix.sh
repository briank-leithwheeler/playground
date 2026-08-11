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
