#!/bin/bash

URL_DL='http://mir7.ovh.net/ovh-applications/hubic/hubiC-Linux/updates-debian.xml'

WORKING_FOLDER=$(mktemp -d)
cd ${WORKING_FOLDER}
wget -q ${URL_DL} -O- |grep deb|awk -F'["]' '{ print $2}' |xargs -L1 -r wget -q
sudo dpkg -i hubiC-Linux-*-linux.deb 2>/dev/null
sudo apt-getinstall -yq
rm -rf ${WORKING_FOLDER}
