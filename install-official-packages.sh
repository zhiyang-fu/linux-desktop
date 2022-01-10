#!/bin/bash

if [ "$EUID" -ne 0 ]
    then echo "must run as root"
        exit
fi

echo "=====> downloading official packages"
echo
# requires sudo
# --noconfirm is used to select all packages from groups
grep -oE '^[^(#|[:space:])]*' pkg_xfce4.txt > packages-official.txt
pacman -Sy --needed $(<packages-official.txt)

