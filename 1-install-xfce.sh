#!/bin/bash

if [ "$EUID" -ne 0 ]
    then echo "must run as root"
        exit
fi

echo "=====> downloading official packages"
echo
# requires sudo
# --noconfirm is used to select all packages from groups
grep -oE '^[^(#|[:space:])]*' pkg_xfce4.txt > pkg_xfce4_clean.txt
pacman -Sy --needed --noconfirm $(<pkg_xfce4_clean.txt)
pacman -Sy --needed $(<pkg_audio.txt)
systemctl enable lightdm.service
systemctl start lightdm.service

