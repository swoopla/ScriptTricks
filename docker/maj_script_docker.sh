#!/bin/bash

WGET='wget -q'

echo  "* Update docker-compose"
URL=$(${WGET} https://github.com/docker/compose/releases/ -O- |egrep "releases/download/[0-9]+.[0-9]+.[0-9]+/docker-compose-Linux-x86_64" | head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O docker-compose
chmod +x docker-compose
echo -e ">>> Move file to docker-compose in /usr/local/bin folder\n"

echo  "* Update docker-compose for ARM only"
for archi in armv6l armv7l; do
  URL=$(${WGET} https://github.com/hypriot/compose/releases/ -O- |egrep "releases/download/[0-9]+.[0-9]+.[0-9]+-raspbian/docker-compose-Linux-${archi}" |awk -F'["]' '{print "https://github.com"$2}' |grep download |head -1)
  ${WGET} ${URL} -O docker-compose-${archi}
done
echo -e ">>> Move file docker-compose-armv* to ARM docker server, in /usr/local/bin folder\n"

echo  "* Update docker-compose bash_completion"
${WGET} https://raw.githubusercontent.com/docker/compose/$(./docker-compose version --short)/contrib/completion/bash/docker-compose -O docker-compose.bash
echo -e ">>> Move docker-compose.bash to /etc/bash_completion.d\n"

echo  "* Update docker-machine"
URL=$(${WGET} https://github.com/docker/machine/releases/ -O- |egrep "releases/download/v[0-9]+.[0-9]+.[0-9]+/docker-machine-Linux-x86_64" |head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O docker-machine
chmod +x docker-machine
echo -e ">>> Move file docker-machine in /usr/local/bin folder\n"

echo  "* Update docker-machine bash_completion"
${WGET} https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine.bash
${WGET} https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine-wrapper.bash
${WGET} https://raw.githubusercontent.com/docker/machine/master/contrib/completion/bash/docker-machine-prompt.bash
echo -e ">>> Move *.bash in /etc/bash_completion.d folder\n"

echo  "* Update docker-volume-local-persist"
URL=$(${WGET} https://github.com/CWSpear/local-persist/releases -O- |egrep "releases/download/v[0-9]+.[0-9]+.[0-9]+/local-persist-linux-amd64" | head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O docker-volume-local-persist
echo -e ">>> Move docker-volume-local-persist in /usr/local/bin folder\n"
${WGET} https://raw.githubusercontent.com/CWSpear/local-persist/master/init/systemd.service -O- |sed -e 's#/bin/#/local/bin/#' > docker-volume-local-persist.service
echo ">>> Move *.service file in /etc/systemd/system folder"
echo -e ">>> To Do: \nsudo systemctl daemon-reload && sudo systemctl enable docker-volume-local-persist && sudo systemctl start docker-volume-local-persist"\n

#echo  "* Update drbdmanage-docker-volume"
#git clone http://git.drbd.org/drbdmanage-docker-volume.git/ && \
#  mv drbdmanage-docker-volume/systemd/drbdmanage-docker-volume ../docker-volume-drbdmanage & \
#  mv drbdmanage-docker-volume/systemd/docker-drbdmanage-plugin.service docker-volume-drbdmanage.service && \
#  mv drbdmanage-docker-volume/systemd/docker-drbdmanage-plugin.socket docker-volume-drbdmanage.socket && \
#  cd .. && \
#  rm -rf drbdmanage-docker-volume || echo '==> Download failed'
#echo ">>> Move docker-volume-drbdmanage.service && docker-volume-drbdmanager.socket in /etc/systemd/system folder"
#echo -e ">>> To Do: \nsudo systemctl daemon-reload && sudo systemctl enable docker-volume-local-persist && sudo systemctl start docker-volume-local-persist\n"

echo  "* Update docker-volume-vsphere"
URL=$(${WGET} https://github.com/vmware/docker-volume-vsphere/releases -O- |egrep "releases/download/[0-9]+.[0-9]+/docker-volume-vsphere.*deb" |head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O docker-volume-vsphere.deb
echo ">>> Move docker-volume-vsphere.deb /usr/local/src"
echo -e ">>> To Do: \nsudo dpkg -i docker-volume-vsphere.deb\n"

echo  "* Update docker-volume-convoy"
URL=$(${WGET} https://github.com/rancher/convoy/releases/ -O- |egrep "releases/download/v[0-9]+.[0-9]+.[0-9]+/convoy.tar.gz" |head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O convoy.tar.gz && \
  tar xvf convoy.tar.gz && \
  rename s/$/.tmp/ convoy && \
  mv convoy.tmp/{convoy,convoy-pdata_tools} . && \
  rm -r convoy.tar.gz convoy.tmp/
echo  ">>> Move {convoy,convoy-pdata_tools} in /usr/local/bin folder"
echo  -e ">>> To Do: \nsudo mkdir -p /etc/docker/plugins/ && sudo bash -c 'echo "unix:///var/run/convoy/convoy.sock" > /etc/docker/plugins/convoy.spec'\n"
