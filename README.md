# control-repo
Puppet control repo for Puppet Essentials Training

https://www.linkedin.com/learning/puppet-essential-training

# Setup master

```
sudo yum install -y https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
sudo yum install -y epel-release
sudo yum install -y puppetserver vim git jq
sudo sed -i.orig -e 's/Xms2g/Xms512m/g' -e 's/Xmx2g/Xmx512m/g' /etc/default/puppetserver
sudo echo "[agent]" >> /etc/puppetlabs/puppet/puppet.conf 
sudo echo "server = master.puppet.vm" >> /etc/puppetlabs/puppet/puppet.conf 
sudo systemctl enable puppetserver
sudo systemctl start puppetserver
sudo mkdir -p /etc/puppetlabs/r10k
sudo /opt/puppetlabs/puppet/bin/gem install r10k
```
