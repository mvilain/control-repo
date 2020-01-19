# control-repo
Puppet control repo for Puppet Essentials Training

https://www.linkedin.com/learning/puppet-essential-training

# Setup master

```
sudo puppet module install puppet/r10k --modulepath=/etc/puppetlabs/code/modules/
sudo puppet apply -e 'class {'r10k': remote => "https://github.com/mvilain/control-repo" }' \
  --modulepath=/etc/puppetlabs/code/modules

puppetserver gem install hiera-eyaml
gem install hiera-eyaml
cd /etc/puppetlabs/puppet
eyaml createkeys
mv /etc/puppetlabs/puppet/keys /etc/puppetlabs/puppet/eyaml
chown -R puppet:puppet /etc/puppetlabs/puppet/eyaml
chmod -R 0500 /etc/puppetlabs/puppet/eyaml
chmod -R 0400 /etc/puppetlabs/puppet/eyaml/*.pem

cp -a eyaml/*.pem /vagrant/
```
