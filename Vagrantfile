

MACHINES = {
  :inetRouter => {
        :box_name => "generic/ubuntu2204",
        :vm_name => "inetRouter",
        :net => [   
                    ["192.168.255.1", 2, "255.255.255.252", "router-net"], 
                    ["192.168.50.10", 8, "255.255.255.0"],

                ]
  },
  :inetRouter2 => {
        :box_name => "generic/ubuntu2204",
        :vm_name => "inetRouter2",
        :net => [   
                    ["192.168.254.1", 2, "255.255.255.252", "router-net2"], 
                    ["192.168.50.11", 8, "255.255.255.0"],

                ]
  },
  :centralRouter => {
        :box_name => "generic/ubuntu2204",
        :vm_name => "centralRouter",
        :net => [
                   ["192.168.255.2", 2, "255.255.255.252", "router-net"],
                   ["192.168.254.2", 3, "255.255.255.252", "router-net2"],
                   ["192.168.0.1",   4, "255.255.255.0", "dir-net"],
                   ["192.168.50.12", 8, "255.255.255.0"],
                ]
  },

  :centralServer => {
        :box_name => "generic/ubuntu2204",
        :vm_name => "centralServer",
        :net => [
                   ["192.168.0.2",    2, "255.255.255.0",  "dir-net"],
                   ["192.168.50.13",  8, "255.255.255.0"],
                ]
  }
 }

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    config.vm.define boxname do |box|
      box.vm.box = boxconfig[:box_name]
      box.vm.host_name = boxconfig[:vm_name]
      
      box.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
       end
       
      boxconfig[:net].each do |ipconf|
        box.vm.network("private_network", ip: ipconf[0], adapter: ipconf[1], netmask: ipconf[2], virtualbox__intnet: ipconf[3])
      end

      if boxconfig.key?(:public)
        box.vm.network "public_network", boxconfig[:public]
      end
      box.vm.provision "shell", inline: <<-SHELL
            export DEBIAN_FRONTEND=noninteractive
            mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
            sed -i '65s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
            systemctl restart sshd
            sudo apt-get install -y traceroute
            sudo apt-get install -y net-tools
          SHELL
      case boxname.to_s
        when "inetRouter"
         box.vm.provision "shell", path: "inetrouter.sh"
        when "inetRouter2"
         box.vm.provision "shell", path: "inetrouter2.sh"
        when "centralRouter"
         box.vm.provision "shell", path: "centralRouter.sh"
        when "centralServer"
	 box.vm.provision "shell", path: "centralServer.sh"
       end   
     end
  end
end


