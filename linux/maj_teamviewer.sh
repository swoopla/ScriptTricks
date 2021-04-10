#!/bin/bash

temp_file="$(mktemp)"
URL_FILE=$(wget -qO- https://www.teamviewer.com/fr/download/linux/  |grep 'linuxFullBetaLink.*\.deb' | sed -e 's/.*href="//;s/".*//')
wget -qO ${temp_file} ${URL_FILE}
sudo dpkg -i ${temp_file} && rm -f ${temp_file}
