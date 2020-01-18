# control-repo
Puppet control repo for Puppet Essentials Training

https://www.linkedin.com/learning/puppet-essential-training

# Setup master

```
sudo puppet module install puppet/r10k --modulepath=/etc/puppetlabs/code/modules/
sudo puppet apply -e 'class {'r10k': remote => "https://github.com/mvilain/control-repo"
}' --modulepath=/etc/puppetlabs/code/modules

```
