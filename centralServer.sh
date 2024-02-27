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
touch centralServer.txt
echo "#
      routes:
      - to: 0.0.0.0/0
        via: 192.168.0.1" >> centralServer.txt
sudo sed -i '/192.168.0.2/r centralServer.txt' /etc/netplan/50-vagrant.yaml
sudo apt install nginx -y
sed -i 's/80 default_server/8080 default_server/g' /etc/nginx/sites-available/default
sudo systemctl enable nginx --now
sudo systemctl daemon-reload
sudo netplan apply
sudo reboot  

