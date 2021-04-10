#!/bin/bash

sudo umount /va/lib/docker
sudo sed -i -e 's#va/#var/#' /etc/fstab 
sudo mkdir /var/lib/docker

sudo apt install libpam-cracklib git fail2ban

chmod 600 /etc/gshadow- /etc/passwd- /etc/group-

/etc/motd
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
SSAPIKeyExchange                no
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
echo 'Storage=persistent' >> /etc/systemd/journald.conf
chmod 0640 /var/log/dpkg.log /var/log/cloud-init.log /var/log/faillog /var/log/lastlog /var/log/btmp /var/log/bootstrap.log 
sudo chmod 600 /etc/crontab
sudo chmod 700 /etc/cron.monthly /etc/cron.d /etc/cron.weekly /etc/cron.hourly /etc/cron.daily 
sudo touch /etc/cron.allow /etc/at.allow
sudo chmod 400 /boot/grub/grub.cfg

#/tmp nodev,nosuid,noexec 
#/var/tmp nodev,nosuid,noexec
#/home nodev,nosuid 
#/run/shm nodev,nosuid,noexec 

sudo usermod -G ssh -a $USER
