#!/bin/bash

echo
echo "installing yay then configuring fonts"
echo

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ../ && rm -rfv yay

echo "=====> installing fonts"
cat pkg_fonts.txt
echo
# requires sudo
# --noconfirm is used to select all packages from groups
yay -Sy --needed --noconfirm $(<pkgs/pkg_fonts.txt)
mkdir -pv $HOME/.config/fontconfig
cp fonts.conf $HOME/.config/fontconfig
