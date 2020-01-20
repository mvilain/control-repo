# control-repo
Puppet control repo for Puppet Essentials Training

https://www.linkedin.com/learning/puppet-essential-training

## Setup master

```
sudo puppet module install puppet/r10k --modulepath=/etc/puppetlabs/code/modules/
sudo puppet apply -e 'class {"r10k": remote => "https://github.com/mvilain/puppet-ess-control-repo" }' \
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

## Setup Testing on local workstation

```
sudo gem install puppet-lint
sudo gem install rspec-puppet puppetlabs_spec_helper rspec-puppet-facts
# download and install https://pm.puppet.com/cgi-bin/pdk_download.cgi?dist=osx&rel=10.13&arch=x86_64&ver=latest
# cd puppet-ess-control-repo/site
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

## ELK (on local workstation in puppet-ess-control-repo)

```
cd puppet-ess-control-repo/site
pdk new module elk

cp .sync.yml elk/
cd elk
pdk update --force

echo "require 'bundler' # https://github.com/puppetlabs/pdk-templates/issues/139" > Rakefile.tmp1
mv Rakefile Rakefile.tmp2
cat Rakefile.tmp[12] > Rakefile; rm Rakefile.tmp* ; rake -T
pdk new class elk; rspec

# create  git@github.com:mvilain/puppet-ess-control-repo-elk.git on github
git init
git add .
git commit -a -m "init elk module"
git remote add origin git@github.com:mvilain/puppet-ess-control-repo-elk.git
git push --set-upstream origin master

# r10k doesn't use submodules; instead 
# https://github.com/git/git/blob/master/contrib/subtree/git-subtree.txt
cd ../..
mv site/elk site/elk.git
git subtree add --prefix site/elk/ git@github.com:mvilain/puppet-ess-control-repo-elk.git master
rm site/elk.git

# go to https://travis-ci.org/ in browser and sign in with Github account
# link github repos; go to puppet-ess-elk repo;
# select *More Options*>*Trigger Build*>*Trigger Custom Build*

```
