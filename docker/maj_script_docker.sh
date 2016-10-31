#!/bin/bash

echo  ">>> Update docker-compose"
URL=$(wget https://github.com/docker/compose/releases/ -qO- |grep "releases/download/[0-9].[0-9].[0-9]/docker-compose-Linux-x86_64" | head -1 |awk -F\" '{ print "https://github.com"$2}'
wget ${URL} -O docker-compose
chmod +x docker-compose
echo  ">>> To Do copy script to docker-* /usr/local/bin/"

echo  ">>> Update docker-compose bash_completion"
wget https://raw.githubusercontent.com/docker/compose/$(./docker-compose version --short)/contrib/completion/bash/docker-compose -O docker-compose.bash
echo  ">>> To Do copy *.bash to /etc/bash_completion.d/"

echo  ">>> Update docker-machine"
URL=$(wget https://github.com/docker/machine/releases/ -qO- |grep "releases/download/v[0-9].[0-9].[0-9]/docker-machine-Linux-x86_64" | head -1 |awk -F\" '{ print "https://github.com"$2}')
wget ${URL} -O docker-machine
chmod +x docker-machine
echo  ">>> To Do copy script to docker-* /usr/local/bin/"

echo  ">>> Update docker-machine bash_completion"
wget https://github.com/docker/machine/blob/master/contrib/completion/bash/docker-machine.bash
wget https://github.com/docker/machine/blob/master/contrib/completion/bash/docker-machine-wrapper.bash
wget https://github.com/docker/machine/blob/master/contrib/completion/bash/docker-machine-prompt.bash
echo  ">>> To Do copy *.bash to /etc/bash_completion.d/"

echo  ">>> Update docker-volume-local-persist"
URL=$(wget https://github.com/CWSpear/local-persist/releases -qO- |grep "releases/download/v[0-9].[0-9].[0-9]/local-persist-linux-amd64" | head -1 |awk -F\" '{ print "https://github.com"$2}')
wget ${URL} -O docker-volume-local-persist
echo  ">>> To Do copy script to docker-* /usr/local/bin/"
wget https://raw.githubusercontent.com/CWSpear/local-persist/master/init/systemd.service -qO- |sed -e 's#/bin/#/local/bin/#' > docker-volume-local-persist.service
echo  ">>> To Do move *.service in /etc/systemd/system"
echo  ">>> To Do: sudo systemctl daemon-reload && sudo systemctl enable docker-volume-local-persist && sudo systemctl start docker-volume-local-persist"

echo  ">>> Update drbdmanage-docker-volume"
git clone http://git.drbd.org/drbdmanage-docker-volume.git/ && cd drbdmanage-docker-volume && \
mv drbdmanage-docker-volume ../docker-volume-drbdmanage
mv systemd/docker-drbdmanage-plugin.service ../docker-volume-drbdmanage.service
mv systemd/docker-drbdmanage-plugin.socket ../docker-volume-drbdmanage.socket
echo  ">>> To Do move *.service && *.socket in /etc/systemd/system"
echo  ">>> To Do: sudo systemctl daemon-reload && sudo systemctl enable docker-volume-local-persist && sudo systemctl start docker-volume-local-persist"

echo  ">>> Update docker-volume-vsphere"
URL=$(wget https://github.com/vmware/docker-volume-vsphere/releases -qO- |grep "releases/download/[0-9].[0-9]/docker-volume-vsphere.*deb" |head -1 |awk -F\" '{ print "https://github.com"$2}')
wget ${URL} -O docker-volume-vsphere.deb
echo  ">>> To Do: sudo dpkg -i docker-volume-vsphere.deb"

echo  ">>> Update docker-volume-convoy"
URL=$(wget https://github.com/rancher/convoy/releases/ -qO- |grep "releases/download/v[0-9].[0-9].[0-9]/convoy.tar.gz |head -1 |awk -F\" '{ print "https://github.com"$2}'")
wget ${URL} -O convoy.tar.gz
tar xvf convoy.tar.gz
mv convoy/{convoy,convoy-pdata_tools} .
rm -rf convoy.tar.gz convoy/
echo  ">>> To Do copy script to docker-* /usr/local/bin/"
echo  ">>> To Do mkdir -p /etc/docker/plugins/"
echo  ">>> To Do bash -c 'echo "unix:///var/run/convoy/convoy.sock" > /etc/docker/plugins/convoy.spec'"

