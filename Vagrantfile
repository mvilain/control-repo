# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

PUPPETLABS_APT_SETUP = <<-EOF
wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
sudo dpkg -i puppet5-release-xenial.deb
sudo apt update
EOF

Vagrant.configure("2") do |config|
  config.vm.define "puppet" do |puppet|
    puppet.vm.provider "virtualbox" do |v|
      v.cpus = 2
      v.memory = 2048
    end
    puppet.vm.network "public_network", bridge: "en1: Ethernet 2", ip: "192.168.50.10"
    puppet.vm.network "forwarded_port", guest: 80, host: 8000, auto_correct: true
    puppet.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
    puppet.vm.hostname = "puppet.local"
    puppet.vm.box = "bento/ubuntu-16.04"
    puppet.vm.provision "shell", inline: PUPPETLABS_APT_SETUP
    puppet.vm.provision "shell", inline: "sudo apt-get install -y puppet-agent puppetserver r10k vim git"
    puppet.vm.provision "shell", inline: "sudo sed -i 's/Xmx2g/Xmx512m/' /etc/default/puppetserver"
    puppet.vm.provision "shell", inline: "sudo sed -i 's/Xms2g/Xms512m/' /etc/default/puppetserver"
    puppet.vm.provision "shell", inline: "sudo systemctl enable puppetserver"
    puppet.vm.provision "shell", inline: "sudo systemctl start puppetserver"
    puppet.vm.provision "shell", inline: %q(puppet apply -e "host {'elk.local': ip => '192.168.50.20'}")
  end
  config.vm.define "elk" do |elk|
    elk.vm.network "public_network", bridge: "en1: Ethernet 2", ip: "192.168.50.20"
    elk.vm.network "forwarded_port", guest: 5601, host: 5601, auto_correct: true
    elk.vm.hostname = "elk.local"
    elk.vm.box = "bento/ubuntu-16.04"
    elk.vm.provision "shell", inline: PUPPETLABS_APT_SETUP
    elk.vm.provision "shell", inline: "sudo apt-get install -y puppet-agent vim"
    elk.vm.provision "shell", inline: %q(puppet apply -e "host {'puppet.local': ip => '192.168.50.10', host_aliases => ['puppet']}")
  end
end

