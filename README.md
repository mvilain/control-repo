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
on local system
```
mkdir ~/.eyaml
cat <-CONFIG > ~/.eyaml/config.yaml
---
pkcs7_private_key: '/Users/mvilain/.eyaml/private_key.pkcs7.pem'
pkcs7_public_key: '/Users/mvilain/.eyaml/public_key.pkcs7.pem'
CONFIG
cp -v p*.pkcs7.pem ~/.eyaml/
# in control-repo copy on local system
mkdir data
cd data
eyaml edit common.yaml
# add 'secret_password: DEC(1)::PKCS7[whatEv3r]!' to file
git add common.yaml
git commit common.yaml -m 'added encrypted secret_password'
```
