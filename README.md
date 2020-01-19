# control-repo
Puppet control repo for Puppet Essentials Training

https://www.linkedin.com/learning/puppet-essential-training

## Setup master

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

## Setup Local workstation

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
# add 'encrypted key/value pair with DEC(1)::PKCS7[whatEv3r]!' to file
git add common.yaml
git commit common.yaml -m 'added encrypted secret_password'
# setup hiera.yaml in top of repo to use eyaml encryption
```

## Testing (on local workstation)

sudo gem install puppet-lint
sudo gem install rspec-puppet puppetlabs_spec_helper rspec-puppet-facts
# download and install https://pm.puppet.com/cgi-bin/pdk_download.cgi?dist=osx&rel=10.13&arch=x86_64&ver=latest
# cd control-repo/site
pdk new module rspec_example
# select the default values for the prompts, but specify the OS as Debian
cp .sync.yml rspec_example/.sync.yml
cd rspec_example/
pdk update
mv Rakefile Rakefile.tmp2
echo "require 'bundler' # https://github.com/puppetlabs/pdk-templates/issues/139" > Rakefile.tmp1
cat Rakefile.tmp[12] > Rakefile; rm Rakefile.tmp* # rake -T
pdk new class rspec_example
rake spec
rake lint
rake syntax
```
