sudo apt update
sudo apt-get -y install firewalld
sudo systemctl enable firewalld
sudo systemctl start firewall
sudo ufw disable
sudo echo "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.conf
sudo sysctl -p
sudo chmod 700 /etc/netplan/00-installer-config.yaml
sudo chmod 700 /etc/netplan/50-vagrant.yaml
sudo chmod 700 /etc/netplan/01-netcfg.yaml
sudo apt-get install openvswitch-switch-dpdk -y
sudo cat /dev/null > /etc/netplan/00-installer-config.yaml
echo "network:
  ethernets:
    eth0:
      dhcp4: true
      dhcp4-overrides:
          use-routes: false
      dhcp6: false
  version: 2" >> /etc/netplan/00-installer-config.yaml
touch inetRouter2.txt
echo "#
      routes:
      - to: 0.0.0.0/0
        via: 192.168.254.2" >> inetRouter2.txt
sudo sed -i '/192.168.254.1/r inetRouter2.txt' /etc/netplan/50-vagrant.yaml
sudo systemctl daemon-reload
sudo netplan apply
sudo firewall-cmd --zone=public --add-masquerade --permanent
sudo firewall-cmd --zone=public --add-forward-port=port=80:proto=tcp:toport=8080:toaddr=192.168.0.2 --permanent
sudo firewall-cmd --reload
sudo reboot

