#!/bin/bash

echo "=====> install official packages"
echo
# requires sudo
# --noconfirm is used to select all packages from groups
grep -oE '^[^(#|[:space:])]*' pkgs/pkg_official.txt > pkgs/pkg_official_clean.txt
sudo pacman -Sy --needed --noconfirm $(<pkgs/pkg_official_clean.txt)

echo "=====> install aur packages"
echo
grep -oE '^[^(#|[:space:])]*' pkgs/pkg_aur.txt > pkgs/pkg_aur_clean.txt
yay -Sy --needed --noconfirm $(<pkgs/pkg_aur_clean.txt)

