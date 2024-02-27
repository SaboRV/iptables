sudo systemctl start ufw
sudo systemctl enable ufw
sudo apt-get install -y knockd
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
touch centralRouter.txt
echo "#
      routes:
      - to: 0.0.0.0/0
        via: 192.168.255.1" >> centralRouter.txt
sudo sed -i '/192.168.255.2/r centralRouter.txt' /etc/netplan/50-vagrant.yaml
sudo systemctl daemon-reload
sudo netplan apply
sudo reboot
