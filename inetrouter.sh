sudo systemctl start ufw
sudo systemctl enable ufw
sudo apt-get install -y knockd
sudo sed -i 's/START_KNOCKD=0/START_KNOCKD=1/g' /etc/default/knockd
sudo cat /dev/null > /lib/systemd/system/knockd.service
echo "[Unit]
Description=Port-Knock Daemon
After=network.target
Requires=network.target
Documentation=man:knockd(1)

[Service]
EnvironmentFile=-/etc/default/knockd
ExecStartPre=/bin/sleep 1
ExecStart=/usr/sbin/knockd $KNOCKD_OPTS
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
SuccessExitStatus=0 2 15
ProtectSystem=full
CapabilityBoundingSet=CAP_NET_RAW CAP_NET_ADMIN

[Install]
WantedBy=multi-user.target" >> /lib/systemd/system/knockd.service
systemctl daemon-reload
systemctl enable knockd

sudo cat /dev/null > /etc/knockd.conf
echo "[options]
    UseSyslog
    Interface = eth1

[opencloseSSH]
    sequence      = 7000,8000,9000
    seq_timeout   = 10
    cmd_timeout   = 60
    tcpflags      = syn
    start_command = /sbin/iptables -I INPUT 3 -s %IP% -p tcp --dport 22 -j ACCEPT
    stop_command  = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT" >> /etc/knockd.conf

sudo debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF

sudo apt-get install -y iptables-persistent

touch /etc/iptables/rules.v4
echo "*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [119:11957]
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate INVALID -j DROP
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i eth0 -p tcp -m tcp --dport 22 -j ACCEPT
COMMIT
*nat
:PREROUTING ACCEPT [3:1196]
:INPUT ACCEPT [1:44]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
COMMIT" >> /etc/iptables/rules.v4

systemctl start knockd

touch /etc/network/if-pre-up.d/iptables
echo "#!/bin/sh
/sbin/iptables-restore < /etc/iptables_rules.ipv4" >> /etc/network/if-pre-up.d/iptables
sudo chmod +x /etc/network/if-pre-up.d/iptables
echo "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p
sudo chmod 700 /etc/netplan/00-installer-config.yaml
sudo chmod 700 /etc/netplan/50-vagrant.yaml
sudo chmod 700 /etc/netplan/01-netcfg.yaml
sudo apt-get install openvswitch-switch-dpdk -y
touch inetRouter.txt
echo "#
      routes:
      - to: 192.168.0.0/16
        via: 192.168.255.2" >> inetRouter.txt
sudo sed -i '/192.168.255.1/r inetRouter.txt' /etc/netplan/50-vagrant.yaml
sudo systemctl daemon-reload
sudo netplan apply
sudo reboot

