# control-repo
Puppet control repo for Puppet Essentials Training

https://www.linkedin.com/learning/puppet-essential-training

## Setup puppet master in virtualbox puppet instance

```
cd puppet-ess  # this is where ngrok and ssh.tar are
vagrant up # wait for puppet and elk boxes to start
vagrant ssh puppet # ssh into run puppet master's box
sudo -s
apt update
apt upgrade -y
cd /root
tar -xvzf /vagrant/ssh.tar.gz
unzip /vagrant/ngrok-stable-linux-amd64.zip

# install volpopluli r10k module
puppet module install puppet/r10k --modulepath=/etc/puppetlabs/code/modules/
puppet apply -e 'class {"r10k": remote => "https://github.com/mvilain/puppet-ess-control-repo.git"}' --modulepath=/etc/puppetlabs/code/modules

# eyaml install and config
puppetserver gem install hiera-eyaml
gem install hiera-eyaml
cd /etc/puppetlabs/puppet
#eyaml createkeys
#mv /etc/puppetlabs/puppet/keys /etc/puppetlabs/puppet/eyaml
mkdir /etc/puppetlabs/puppet/eyaml
cp -v /vagrant/p*.pkcs7.pem /etc/puppetlabs/puppet/eyaml
chown -R puppet:puppet /etc/puppetlabs/puppet/eyaml
chmod -R 0500 /etc/puppetlabs/puppet/eyaml
chmod -R 0400 /etc/puppetlabs/puppet/eyaml/*.pem
ls -lah /etc/puppetlabs/puppet/eyaml
#rm -f /vagrant/p*.pkcs7.pem && cp -av eyaml/*.pem /vagrant/

# deploy control-repo code and run server
r10k deploy environment -pv
puppet agent -t
lsof -i TCP -P
# run ngrok and paste the URL into the repo's webhook
#    http://puppet:puppet@NGROK_URL/payload
# in another window
cd puppet-ess
vagrant ssh vagrant
sudo -s
cd /etc/puppetlabs/code/environments/production

```

## Setup Local workstation

```
# install rbenv either with brew or ports
# add 'eval "$(rbenv init -)"' to ~/.bash_profile
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash
gem install bundler
bundle config set specific_platform true

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

## Setup webhook on github

```
cd
```

## Setup Testing on local workstation

```

gem install puppet-lint
gem install rspec-puppet puppetlabs_spec_helper rspec-puppet-facts
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

## ELK Travis-CI testing (on local workstation in puppet-ess-control-repo)

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
# https://codewinsarguments.co/2016/05/01/git-submodules-vs-git-subtrees/
# https://github.com/git/git/blob/master/contrib/subtree/git-subtree.txt
cd ../..
mv site/elk site/elk.git
git subtree add --prefix site/elk/ git@github.com:mvilain/puppet-ess-control-repo-elk.git master
rm site/elk.git

# go to https://travis-ci.org/ in browser and sign in with Github account
# link github repos; go to puppet-ess-elk repo;
# select *More Options*>*Trigger Build*>*Trigger Custom Build*
```

## ELK Beaker testing (broken) (on local workstation in puppet-ess-control-repo)

```
cd puppet-ess-control-repo/site/elk
# edit elk Gemfile to add
## group :acceptance do
##  gem "beaker-rspec"
##  gem "beaker-vagrant"
## end

bundle install
mkdir -p spec/acceptance/nodesets spec/acceptance/classes
# vim spec/acceptance/nodesets/default.yml # from puppetforge's apache module
# vim spec/spec_helper_acceptance.rb # use version in code files
# vim spec/acceptance/classes/elk_spec.rb
bundle exec rake beaker
```

## ELK Module (on local workstation)

```
add 'mod 'elastic-kibana', '6.3.1'' to Puppetfile with dependencies
#add site/elk/manifests/init.pp
#add site/elk/files/filebeats.conf
git subtree push -P site/elk git@github.com:mvilain/puppet-ess-control-repo-elk.git master
```

## ELK vagrant instance

```
vagrant ssh elk
sudo puppet agent -t # generate a key to sign
exit

# go to puppet server
vagrant ssh puppet
sudo puppetserver ca sign --all

# https://github.com/elastic/puppet-elasticsearch/issues/982
sudo r10k deploy environment -pv
puppet generate types --environment production
exit

# go back ELK vagrant instance
sudo puppet agent -t





















```
