#! /bin/bash

# This is Zhiyang's Arch Linux Installation Script.
# Based on krushndayshmookh.github.io/krushn-arch
# https://github.com/mietinen/archer/blob/master/archer.sh
# https://www.youtube.com/watch?v=ybvwikNlx9I
# https://octetz.com/docs/2020/2020-2-16-arch-windows-install/
ENCRYPT=false #setup dm-crypt/luks on root partition

archiso() {
echo "Zhiyang's Arch Installer"

# Set up network connection
read -p 'Are you connected to internet? [y/N]: ' neton
if ! [ $neton = 'y' ] && ! [ $neton = 'Y' ]
then
    echo "Connect to internet to continue..."
    exit
fi

# Set up keyboard and time
loadkeys us
timedatectl set-ntp true

# Filesystem mount warning
echo "This script will create and format the partitions as follows:"
echo "/dev/sda1 - 512Mib will be mounted as /boot/efi"
echo "/dev/sda2 - rest of space will be mounted as /"
read -p 'Continue? [y/N]: ' fsok
if ! [ $fsok = 'y' ] && ! [ $fsok = 'Y' ]
then
    echo "Edit the script to continue..."
    exit
fi

# PARTITION
# to create the partitions programmatically (rather than manually)
# https://superuser.com/a/984637
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
  +512M # 512 MB boot parttion
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

# ENCRYPT
if [ "$ENCRYPT" = true ]; then
cryptsetup -y --use-random luksFormat /dev/sda2
# -y: interactively requests the passphrase twice
# --use-random: uses /dev/random to produce keys
cryptsetup luksOpen /dev/sda2 cryptroot
fi

# FORMAT and MOUNT
# the partitions using GPT for efi boot
mkfs.fat -F 32 /dev/sda1

if [ "$ENCRYPT" = true ]; then
    mkfs.ext4 /dev/mapper/cryptroot
    mount /dev/mapper/cryptroot /mnt
else
    mkfs.ext4 /dev/sda2
    mount /dev/sda2 /mnt
fi

mkdir -pv /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
#mkswap /dev/sda2
#swapon /dev/sda2


# Install base/essential packages using pacstrap
# https://www.archlinux.org/packages/core/x86_64/linux
# https://ww.archlinux.org/packages/core/any/linux-firmware
# https://archlinux.org/packages/core/any/base
# https://www.archlinux.org/groups/x86_64/base-devel
echo "Starting pacstrap installation.."
pacstrap /mnt base base-devel linux linux-firmware vim git intel-ucode

# zsh grml-zsh-config grub os-prober intel-ucode efibootmgr dosfstools freetype2 fuse2 mtools iw wpa_supplicant dialog xorg xorg-server xorg-xinit mesa xf86-video-intel plasma konsole dolphin

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
}

# Chroot into new system
transit() {
    #copy this file
    cp "$0" /mnt/root/arch_install.sh
    cp 1-install-xfce.sh /mnt/root/install-xfce.sh
    arch-chroot /mnt /bin/bash /root/arch_install.sh --chroot
}

chroot() {
# Time zone
ln -sf /usr/share/zoneinfo/MST /etc/localtime
hwclock --systohc

#Localization
locale='en_US.UTF-8'
# uncomment by removing #
sed -i "/^#$locale/s/^#//" /etc/locale.gen
locale-gen
echo "LANG=$locale" >> /etc/locale.conf

#Hostname
echo "chaos" >> /etc/hostname

if [ "$ENCRYPT" = true ]; then
#see https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Configuring_mkinitcpio
sed -i '/^HOOKS=/s/\(filesystems\)/encrypt \1/' /etc/mkinitcpio.conf
sed -i '/^HOOKS=/s/\(modconf\)/keyboard keymap \1/' /etc/mkinitcpio.conf
sed -i ':s;/^HOOKS=/s/\(\<\S*\>\)\(.*\)\<\1\>/\1\2/g;ts;/^HOOKS=/s/  */ /g' /etc/mkinitcpio.conf
fi
mkinitcpio -P

# pacman and makepkg conf
sed -i "s/^#\(Color\)/\1/" /etc/pacman.conf
sed -i "s/^#\(ParallelDownloads\)/\1/" /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

# bootloader
pacman --noconfirm --needed -Sy grub efibootmgr
if [ "$ENCRYPT" = true ]; then
rootid=$(blkid --output export /dev/sda2 | sed --silent 's/^UUID=//p')
# sed -i '/^GRUB_CMDLINE_LINUX=/s/=""/="cryptdevice=UUID='$rootid':cryptroot root=\/dev\/mapper\/cryptroot"/' /etc/default/grub
# sed -i /GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX=\"cryptdevice=/dev/disk/by-uuid/${rootid}:cryptroot\" /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID={root_uuid}:cryptlvm rootfstype={ext4}\"/' /etc/default/grub
#for boot encrypted scenario
#sed -i 's/^#\?\(GRUB_ENABLE_CRYPTODISK=\).\+/\1y/' /etc/default/grub
fi

# grub-install
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

#user and password
useradd -m -G wheel zyfu
#-G adds to group -m creates a home directory
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for new user zyfu"
passwd zyfu

#install xfce desktop manager
/bin/bash /root/install-xfce.sh

echo "Installed successfully!"
echo "umount -R /mnt"
echo "before reboot"
}

if [ "$1" != "--chroot" ]; then
    archiso
    transit
else
    chroot
fi
