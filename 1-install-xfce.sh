#!/bin/bash

if [ "$EUID" -ne 0 ]
    then echo "must run as root"
        exit
fi

echo "=====> downloading official packages"
echo
# requires sudo
# --noconfirm is used to select all packages from groups
grep -oE '^[^(#|[:space:])]*' pkgs/pkg_xfce4.txt > pkgs/pkg_xfce4_clean.txt
pacman -Sy --needed --noconfirm $(<pkgs/pkg_xfce4_clean.txt)
pacman -Sy --needed $(<pkgs/pkg_audio.txt)
systemctl enable lightdm.service
systemctl start lightdm.service
systemctl enable bluetooth.service
systemctl start bluetooth.service
systemctl enable cups.service
systemctl start cups.service

