#!/bin/sh
#This script is to setup a default install of Alpine Linux installed to disk.
# The Following Settings where used in the install
# ISO: alpine-virt-3.12.0-x86_64.iso
# Disk: Blank
# Keyboard: us | Variant: us
# Hostname: warrior
# Network: eth0 dhcp no manual config
# Root Password: archiveteam
# UTC Timezone
# No HTTP Proxy
# Mirror: dl-2.alpinelinux.org
# SSH Server: None
# NTP Client: chrony
# Disk to use: sda | Yes Erase | Use it: sys
# =REBOOT=
# apk add openssl
# wget https://raw.githubusercontent.com/ArchiveTeam/Ubuntu-Warrior/master/stage.sh

REPO_PREFIX=https://raw.githubusercontent.com/ArchiveTeam/Ubuntu-Warrior/
BRANCH=master

if [ -f /root/repo_prefix.txt ]; then
    REPO_PREFIX=`cat /root/repo_prefix.txt`
fi
if [ -f /root/branch.txt ]; then
    BRANCH=`cat /root/branch.txt`
fi

# /etc/inittab
rm /etc/inittab
cat <<EOT >> /etc/inittab
::sysinit:/bin/sh -c "cat /root/splashes/at-splash-startup-640x400-32.fb > /dev/fb0"
::sysinit:/sbin/openrc sysinit --quiet > /dev/null 2>&1
::sysinit:/sbin/openrc boot --quiet > /dev/null 2>&1
::wait:/sbin/openrc default --quiet > /dev/null 2>&1

# Set up a couple of getty's
tty1::respawn:/bin/sh /root/boot.sh
tty2::respawn:/sbin/getty 38400 tty2
tty3::respawn:/sbin/getty 38400 tty3
tty4::respawn:/sbin/getty 38400 tty4
tty5::respawn:/sbin/getty 38400 tty5
tty6::respawn:/sbin/getty 38400 tty6

# Stuff to do for the 3-finger salute
::ctrlaltdel:/bin/sh -c "cat /root/splashes/at-splash-restart-640x400-32.fb > /dev/fb0"
::ctrlaltdel:/sbin/reboot

# Stuff to do before rebooting
::shutdown:/bin/sh -c "cat /root/splashes/at-splash-shutdown-640x400-32.fb > /dev/fb0"
::shutdown:/sbin/openrc shutdown --quiet > /dev/null 2>&1
EOT

# Disable the console screensaver
if ! grep "consoleblank=0" /etc/update-extlinux.conf; then
    sed -i -E -e 's/(default_kernel_opts="[^"]+)/\1 consoleblank=0/' /etc/update-extlinux.conf
    update-extlinux
fi

echo 'The root password is "archiveteam".' >> /etc/issue
cat >/etc/motd <<END
==== Archive Team Warrior ====

The warrior instance is running within a Docker container.
For details, see the ArchiveTeam wiki and Docker documentation.
END

# add community sources
echo "http://dl-3.alpinelinux.org/alpine/v3.12/community" >> /etc/apk/repositories
set > /root/env.sh

#download boot script
wget ${REPO_PREFIX}${BRANCH}/boot.sh -O /root/boot.sh
chmod +x /root/boot.sh

# Download splashes
mkdir /root/splashes
wget ${REPO_PREFIX}${BRANCH}/splash/splashes/at-splash-ready-640x400-32.fb -O /root/splashes/at-splash-ready-640x400-32.fb
wget ${REPO_PREFIX}${BRANCH}/splash/splashes/at-splash-update-640x400-32.fb -O /root/splashes/at-splash-update-640x400-32.fb
wget ${REPO_PREFIX}${BRANCH}/splash/splashes/at-splash-outdated-640x400-32.fb -O /root/splashes/at-splash-outdated-640x400-32.fb
wget ${REPO_PREFIX}${BRANCH}/splash/splashes/at-splash-startup-640x400-32.fb -O /root/splashes/at-splash-startup-640x400-32.fb
wget ${REPO_PREFIX}${BRANCH}/splash/splashes/at-splash-shutdown-640x400-32.fb -O /root/splashes/at-splash-shutdown-640x400-32.fb
wget ${REPO_PREFIX}${BRANCH}/splash/splashes/at-splash-restart-640x400-32.fb -O /root/splashes/at-splash-restart-640x400-32.fb

# Update, install and configure framebuffer
apk update
apk add v86d
echo "sbin/v86d" > /etc/mkinitfs/features.d/v86d.files
# https://wiki.alpinelinux.org/wiki/Uvesafb, https://wiki.archlinux.org/index.php/uvesafb#Define_a_resolution
# the following file might change in future Alpine versions
cat <<EOT >> /etc/mkinitfs/mkinitfs.conf
features="ata base ide scsi usb virtio ext4 kms v86d"
files="/etc/modprobe.d/uvesafb.conf"
EOT
echo "options uvesafb mode_option=640x400-32 scroll=ywrap" > /etc/modprobe.d/uvesafb.conf
mkinitfs -o /boot/initramfs-virt
# the following file might change in future Alpine versions
sed -i '/modules=/c modules=sd-mod,usb-storage,ext4,uvesafb' /etc/update-extlinux.conf
update-extlinux

#Update and install Docker
apk update
apk add docker
rc-update add docker boot
echo "cgroup  /sys/fs/cgroup  cgroup  defaults  0   0" >> /etc/fstab

# Reduce boot delay in boot configuration update script to 1 second (minimum)
# In case update-extlinux is run and regenerates the boot configuration file
sed -i '/timeout=/c timeout=1' /etc/update-extlinux.conf
update-extlinux

# Reduce boot delay to 0.1 seconds (minimum)
sed -i '/TIMEOUT /c TIMEOUT 1' /boot/extlinux.conf # https://stackoverflow.com/a/43305210

echo "Script Completed, poweroff the virtual machine and package for upload!"
