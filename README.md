# control-repo
Puppet control repo for Puppet Essentials Training

https://www.linkedin.com/learning/puppet-essential-training

## Setup puppet master in virtualbox puppet instance

- create puppet master and elk Vagrant instances
- install and configure r10k on puppet master instance
- install & configure eyaml on puppetserver, puppet VM, and local workstation
- deploy control-repo code and use ngrok to service webhook

```
cd puppet-ess
# clone this git repo and use Vagrantfile instead of example code 
# it uses public network instead of private
# ngrok won't work in private network
vagrant up
#-01--------------------------------------------
vagrant ssh puppet
sudo -s
#apt-get update
#apt-get upgrade -y
cd /root
tar -xvzf /vagrant/ssh.tar.gz
unzip /vagrant/ngrok-stable-linux-amd64.zip
#-02--------------------------------------------
puppet module install puppet/r10k --modulepath=/etc/puppetlabs/code/modules/
puppet apply -e 'class {"r10k": remote => "https://github.com/mvilain/puppet-ess-control-repo.git"}' --modulepath=/etc/puppetlabs/code/modules
#-03-------------------------------------------
echo ""                                >>/etc/puppetlabs/puppet/puppet.conf
echo "[main]"                          >>/etc/puppetlabs/puppet/puppet.conf
echo "reports = store, puppetdb, http" >>/etc/puppetlabs/puppet/puppet.conf
echo ""                                >>/etc/puppetlabs/puppet/puppet.conf
tail /etc/puppetlabs/puppet/puppet.conf
#-04--------------------------------------------
## ensure highline is installed on workstation in rbenv
gem install hiera-eyaml
puppetserver gem install hiera-eyaml
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
#-05--------------------------------------------
cd /etc/puppetlabs/code/environments
ls -l production
r10k deploy environment -pv
ls -l production
#-06--------------------------------------------
puppet agent -t
netstat -tulpn     # show ports
lsof -i TCP -P
#-07--------------------------------------------
# run ngrok and paste the URL into the repo's webhook
/root/ngrok http 8088
#    http://puppet:puppet@NGROK_URL/payload
# in another window
cd puppet-ess
vagrant ssh vagrant
sudo -s
cd /etc/puppetlabs/code/environments/production
```

## Setup Local workstation

```
#-08--------------------------------------------
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
#-09--------------------------------------------
# under github's repo for puppet-ess-control-repo settings click on Webhooks
# add a webhook with URL http://puppet:puppet@NGROK_URL/payload
```

## Setup rspec Testing on local workstation

```
#-10--------------------------------------------
gem install puppet-lint
gem install rspec-puppet puppetlabs_spec_helper rspec-puppet-facts
# download and install https://pm.puppet.com/cgi-bin/pdk_download.cgi?dist=osx&rel=10.13&arch=x86_64&ver=latest
# cd puppet-ess-control-repo/site
pdk new module rspec_example
# select the default values for the prompts, but specify the OS as Debian
cp .sync.yml rspec_example/.sync.yml
cd rspec_example/
pdk update

# https://github.com/puppetlabs/pdk-templates/issues/139"
mv Rakefile Rakefile.tmp2
echo "require 'bundler' > Rakefile.tmp1
cat Rakefile.tmp[12] > Rakefile; rm Rakefile.tmp* # rake -T
pdk new class rspec_example
rake spec
rake lint
rake syntax
```
#-11--------------------------------------------
## ELK Travis-CI testing (on local workstation in control-repo)

- create new elk module on local workstation
```
cd puppet-ess-control-repo/site
pdk new module elk

cp .sync.yml elk/
cd elk
pdk update --force

# https://github.com/puppetlabs/pdk-templates/issues/139
echo "require 'bundler'" > Rakefile.tmp1
mv Rakefile Rakefile.tmp2
cat Rakefile.tmp[12] > Rakefile; rm Rakefile.tmp* ; rake -T
pdk new class elk; rspec
```

- create separate github repo puppet-ess-control-repo-elk.git
```
#-12--------------------------------------------
git init
git add .
git commit -a -m "init elk module"
git remote add origin git@github.com:mvilain/puppet-ess-control-repo-elk.git
git push --set-upstream origin master
```

- create subtree of elk module
```
#-13--------------------------------------------
# r10k doesn't use submodules; instead subtrees
# https://codewinsarguments.co/2016/05/01/git-submodules-vs-git-subtrees/
# https://github.com/git/git/blob/master/contrib/subtree/git-subtree.txt
cd ../..
mv site/elk site/elk.git
git subtree add --prefix site/elk/ git@github.com:mvilain/puppet-ess-control-repo-elk.git master
rm site/elk.git
```

- sign into Travis-CI with github account
```
# link github repos; go to puppet-ess-elk repo;
# select *More Options*>*Trigger Build*>*Trigger Custom Build*
```

## ELK Beaker testing (on local workstation in puppet-ess-control-repo)

**this is currently broken--beaker runs the virtual machine but it can't connect**

```
#-14--------------------------------------------
#
# this is currently broken--beaker runs the virtual machine but it can't connect
#
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

- add elastic-kibana puppetfile dependencies
```
#-15--------------------------------------------
#add site/elk/manifests/init.pp
#add site/elk/files/filebeats.conf
git subtree push -P site/elk git@github.com:mvilain/puppet-ess-control-repo-elk.git master
```

## ELK vagrant instance

```
#-16a--------------------------------------------
vagrant ssh elk
sudo puppet agent -t # generate a key to sign
exit
```
- fix puppet type dependencies on puppet master
```
#-16b--------------------------------------------
vagrant ssh puppet
sudo puppetserver ca sign --all
sudo r10k deploy environment -pv

# https://github.com/elastic/puppet-elasticsearch/issues/982
puppet generate types --environment production
```

- re-apply puppet configuration on elk instance
```
#-17--------------------------------------------
sudo puppet agent -t

# requires 2nd run to pick up filebeat dependencies
sudo puppet agent -t
ps -ef | grep -E "elastic|kibana|logstash|filebeat"
sleep 60; lsof -i TCP -P   # java takes time to startup
```

## REPORTING (puppetboard on puppet server)


**this is currently broken--puppetboard has parts that use python2 (wsgi)**

```
#
# https://github.com/voxpupuli/puppetboard/issues/527
#
puppet config print reportdir --section main
cd /opt/puppetlabs/puppet/cache/reports/puppet.local/
# look for 'evaluation_time' to improve speed of puppet runs
```

### setup puppetdb

- modify Puppetfile adding puppetdb and dependencies
- add profile::puppetdb with code from module README
- add profile::puppetdb class to role::master
- commit, push, and run puppet on master

### add reporting section [main] to puppet.conf on server and restart

```
vim /etc/puppetlabs/puppet/puppet.conf

[main]
reports = store, puppetdb, http


systemctl restart puppetserver  # this will take a moment -- it's java
systemctl status puppetserver --no-pager
```

### add puppetboard module and dependencies

- modify Puppetfile adding puppetboard and dependencies (current modules don't work)
- modify Puppetfile adding apache module and it's dependencies
- create profile/manifests/puppetboard.pp
- add profile::puppetboard to role::master.pp

**this currently requires puppet agent -t be run twice. Apparently the way the puppetboard
module is written, it compiles on the master to run the postgresql resource before
all it's resources are installed. The user, group, and binaries of postgresql aren't installed in the right order before the application is setup **

### run puppet on master
```
r10k deploy environment -pv
puppet agent -t
# http://localhost:8000
```

## MONITORING PUPPET WITH ELK

- edit /etc/puppetlabs/puppetserver/logback.xml (note 2 appender blocks)
- copy puppetserver.log appender block and paste below
```
change name to "JSON"
change encoder to be <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
```
- near EOF, there's appender-ref lines. Add another for JSON entry
- copy/paste code /control-repo/request-logging.xml below 1st appender in /etc/puppetlabs/puppetserver/request-logging.xml
- add another appender-ref entry for JSON near end of file
- restart puppetserver
```
systemctl restart puppetserver # java...it will take a while
```

- setup elk prospectors by editting site/elk/manifests/filebeat.pp
```
# add an empty array parameter for prospectors to elk::filebeat class
# add $prospectors variable to epp template
```

- create site/profile/manifests/filebeat_puppetserver.pp
- edit site/role/manfests/master.pp to add "filebeat_puppetserver"
- ensure elk server is up and running
- run puppet on master to add puppetserver logs to ELK stack


