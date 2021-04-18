#!/bin/bash

umount /va/lib/docker
sed -i -e 's#va/#var/#' /etc/fstab 
mkdir /var/lib/docker
mount /var/lib/docker

apt install -yqq libpam-cracklib git fail2ban figlet unattended-upgrade

#https://cloriou.fr/2020/04/02/ajouter-motd-dynamique-debian/
rm -f /etc/update-motd.d/10-uname
pushd /etc/update-motd.d
cat > colors << EOF
NONE="\033[m"
WHITE="\033[1;37m"
GREEN="\033[1;32m"
RED="\033[0;32;31m"
YELLOW="\033[1;33m"
BLUE="\033[34m"
CYAN="\033[36m"
LIGHT_GREEN="\033[1;32m"
LIGHT_RED="\033[1;31m"
EOF

cat > 00-hostname << EOF
#!/bin/sh

. /etc/update-motd.d/colors

printf "\n"\$LIGHT_RED
figlet "  "\$(hostname -s)
printf \$NONE
printf "\n"
EOF

cat > 10-banner << EOF
#!/bin/bash
#
#    Copyright (C) 2009-2010 Canonical Ltd.
#
#    Authors: Dustin Kirkland <kirkland@canonical.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

. /etc/update-motd.d/colors

[ -r /etc/update-motd.d/lsb-release ] && . /etc/update-motd.d/lsb-release

if [ -z "\$DISTRIB_DESCRIPTION" ] && [ -x /usr/bin/lsb_release ]; then
    # Fall back to using the very slow lsb_release utility
    DISTRIB_DESCRIPTION=\$(lsb_release -s -d)
fi

re='(.*\()(.*)(\).*)'
if [[ \$DISTRIB_DESCRIPTION =~ \$re ]]; then
    DISTRIB_DESCRIPTION=$(printf "%s%s%s%s%s" "\${BASH_REMATCH[1]}" "\${YELLOW}" "\${BASH_REMATCH[2]}" "\${NONE}" "\${BASH_REMATCH[3]}")
fi

echo -e "  "\$DISTRIB_DESCRIPTION "(kernel "\$(uname -r)")\n"

# Update the information for next time
printf "DISTRIB_DESCRIPTION=\"%s\"" "\$(lsb_release -s -d)" > /etc/update-motd.d/lsb-release &
EOF

cat > 20-sysinfo << EOF
#!/bin/bash
proc=\$(grep -i "^model name" /proc/cpuinfo | awk -F": " '{print \$2}')
memfree=\$(grep MemFree /proc/meminfo | awk {'print \$2'})
memtotal=\$(grep MemTotal /proc/meminfo | awk {'print \$2'})
uptime=\$(uptime -p)
addrip=\$(hostname -I | cut -d " " -f1)
# Récupérer le loadavg
read one five fifteen rest < /proc/loadavg

# Affichage des variables
printf "  Processeur : \$proc"
printf "\n"
printf "  Charge CPU : \$one (1min) / \$five (5min) / \$fifteen (15min)"
printf "\n"
printf "  Adresse IP : \$addrip"
printf "\n"
printf "  RAM : $((\${memfree:-1024}/1024))MB libres / \$((${memtotal:-1024}/1024))MB"
printf "\n"
printf "  Uptime : \$uptime"
printf "\n"
printf "\n"
EOF
chmod 755 *
ln -sf /run/motd.dynamic.new /etc/motd
popd

chmod 600 /etc/gshadow- /etc/passwd- /etc/group-

echo "------------------------------------------------------------
WARNING: You must have specific authorization to access this
machine. Unauthorized users will be logged, monitored, and
could be pursued.
------------------------------------------------------------" |tee /etc/issue /etc/issue.net 1>/dev/null

echo 'TMOUT=600' > /etc/profile.d/secu.conf
echo 'umask 077' >> /etc/profile.d/secu.conf

echo 'CREATE_HOME yes' >> /etc/login.defs
echo 'PASS_MIN_DAYS 1' >> /etc/login.defs
echo 'PASS_MAX_DAYS 60' >> /etc/login.defs

cat >> /etc/ssh/sshd_config << EOF
Protocol                        2
LogLevel                        INFO
X11Forwarding                   no
LoginGraceTime                  60
Compression                     no
IgnoreUserKnownHosts            yes
Banner                          /etc/issue.net
AllowUsers                      *
AllowGroups                     ssh
StrictModes                     yes
DenyUsers                       nobody
DenyGroups                      nobody
AllowAgentForwarding            no
AllowTcpForwarding              no
AllowStreamLocalForwarding      no
PermitTunnel                    no
PermitUserRC                    no
GatewayPorts                    no
RekeyLimit                      512M\s+6h
PubkeyAuthentication            yes
PasswordAuthentication          no
KbdInteractiveAuthentication    no
KerberosAuthentication          no
HostbasedAuthentication         no
GSSAPIAuthentication            no
GSSAPIKeyExchange               no
AllowTCPForwarding              no
ClientAliveInterval             300
ClientAliveCountMax             0
LoginGraceTime                  60
KexAlgorithms                   diffie-hellman-group-exchange-sha256
MACs                            hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
Ciphers                         chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
PermitUserEnvironment           no
PermitEmptyPasswords            no
PermitRootLogin                 no
HostbasedAuthentication         no
IgnoreRhosts                    yes
MaxAuthTries                    4
EOF
chmod 600 /etc/ssh/sshd_config
sshd -t && service ssh restart

echo 'Storage=persistent' >> /etc/systemd/journald.conf && service systemd-journald restart

chmod 0640 /var/log/dpkg.log /var/log/cloud-init.log /var/log/faillog /var/log/lastlog /var/log/btmp /var/log/bootstrap.log 
chmod 600 /etc/crontab
chmod 700 /etc/cron.monthly /etc/cron.d /etc/cron.weekly /etc/cron.hourly /etc/cron.daily 
touch /etc/cron.allow /etc/at.allow
chmod 400 /boot/grub/grub.cfg

sed -i -e 's#\(/tmp.*defaults\)#\1,nodev,nosuid,noexec#' /etc/fstab
sed -i -e 's#\(/home.*defaults\)#\1,nodev,nosuid#' /etc/fstab

for _user in $(grep home /etc/passwd |cut -d: -f1); do
    usermod -G ssh -a $_user
done
 
cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,codename=${distro_codename}-updates";
        "origin=Debian,codename=${distro_codename},label=Debian";
        "origin=Debian,codename=${distro_codename},label=Debian-Security";
};
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "false";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-WithUsers "false";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
EOF