#!/bin/bash

WGET='wget -q'

echo  "* Update docker-compose"
URL=$(${WGET} https://github.com/docker/compose/releases/ -O- |grep "releases/download/[0-9].[0-9].[0-9]/docker-compose-Linux-x86_64" | head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O docker-compose
chmod +x docker-compose
echo -e ">>> To Do copy script to docker-* /usr/local/bin/\n"

echo  "* Update docker-compose for ARM only"
for archi in arm6l arm7l; do
  URL=$(${WGET} https://github.com/hypriot/compose/releases/ -O- |grep "releases/download/[0-9].[0-9].[0-9]-raspbian/docker-compose-Linux-${archi}" |awk -F'["]' '{print "https://github.com"$2}' |grep download |head -1)
  ${WGET} ${URL} -O docker-compose-${archi}
done

echo  "* Update docker-compose bash_completion"
${WGET} https://raw.githubusercontent.com/docker/compose/$(./docker-compose version --short)/contrib/completion/bash/docker-compose -O docker-compose.bash
echo -e ">>> To Do copy *.bash to /etc/bash_completion.d/\n"

echo  "* Update docker-machine"
URL=$(${WGET} https://github.com/docker/machine/releases/ -O- |grep "releases/download/v[0-9].[0-9].[0-9]/docker-machine-Linux-x86_64" |head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O docker-machine
chmod +x docker-machine
echo -e ">>> To Do copy script to docker-* /usr/local/bin/\n"

echo  "* Update docker-machine bash_completion"
${WGET} https://github.com/docker/machine/blob/master/contrib/completion/bash/docker-machine.bash
${WGET} https://github.com/docker/machine/blob/master/contrib/completion/bash/docker-machine-wrapper.bash
${WGET} https://github.com/docker/machine/blob/master/contrib/completion/bash/docker-machine-prompt.bash
echo -e ">>> To Do copy *.bash to /etc/bash_completion.d/\n"

echo  "* Update docker-volume-local-persist"
URL=$(${WGET} https://github.com/CWSpear/local-persist/releases -O- |grep "releases/download/v[0-9].[0-9].[0-9]/local-persist-linux-amd64" | head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O docker-volume-local-persist
echo  ">>> To Do copy script to docker-* /usr/local/bin/"
${WGET} https://raw.githubusercontent.com/CWSpear/local-persist/master/init/systemd.service -O- |sed -e 's#/bin/#/local/bin/#' > docker-volume-local-persist.service
echo  ">>> To Do move *.service in /etc/systemd/system"
echo -e ">>> To Do: sudo systemctl daemon-reload && sudo systemctl enable docker-volume-local-persist && sudo systemctl start docker-volume-local-persist\n"

echo  "* Update drbdmanage-docker-volume"
git clone http://git.drbd.org/drbdmanage-docker-volume.git/ && cd drbdmanage-docker-volume && \
mv drbdmanage-docker-volume ../docker-volume-drbdmanage
mv systemd/docker-drbdmanage-plugin.service ../docker-volume-drbdmanage.service
mv systemd/docker-drbdmanage-plugin.socket ../docker-volume-drbdmanage.socket
cd .. && rm -rf drbdmanage-docker-volume
echo  ">>> To Do move *.service && *.socket in /etc/systemd/system"
echo  ">>> To Do: sudo systemctl daemon-reload && sudo systemctl enable docker-volume-local-persist && sudo systemctl start docker-volume-local-persist\n"

echo  "* Update docker-volume-vsphere"
URL=$(${WGET} https://github.com/vmware/docker-volume-vsphere/releases -O- |grep "releases/download/[0-9].[0-9]/docker-volume-vsphere.*deb" |head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O docker-volume-vsphere.deb
echo -e ">>> To Do: sudo dpkg -i docker-volume-vsphere.deb\n"

echo  "* Update docker-volume-convoy"
URL=$(${WGET} https://github.com/rancher/convoy/releases/ -O- |grep "releases/download/v[0-9].[0-9].[0-9]/convoy.tar.gz" |head -1 |awk -F\" '{ print "https://github.com"$2}')
${WGET} ${URL} -O convoy.tar.gz
tar xvf convoy.tar.gz
rename s/$/.tmp/ convoy
mv convoy.tmp/{convoy,convoy-pdata_tools} .
rm -r convoy.tar.gz convoy.tmp/
echo  ">>> To Do copy script to docker-* /usr/local/bin/"
echo  ">>> To Do mkdir -p /etc/docker/plugins/"
echo -e ">>> To Do bash -c 'echo "unix:///var/run/convoy/convoy.sock" > /etc/docker/plugins/convoy.spec'\n"
