class profile::puppetboard {

  # independent but needed to serve puppetboard web site
  class { 'apache': }
  #installs for system python (e.g. python2)
  class { 'apache::mod::wsgi': }
  -> package{'libapache2-mod-wsgi-py3': ensure => present, }
  
  # puppetdb needs postgresql server installed; doesn't install package in right order
  # but it's ordering is wrong when called inside puppetboard
  # which means you can't create a puppetboard server with a puppetdb on another host
  package {'postgresql': ensure  => present, }

  # https://github.com/voxpupuli/puppetboard/issues/527
  # module puppetboard 1.1 requires python 3.[678]
  # 'system' is default puppetboard virtual environment [python 2.7 on Ubuntu 18.04]
  # fixed by adding
  #  puppetboard::virtualenv_version: "3.6"
  # in data/common.yaml
  #
  # https://puppet.com/blog/troubleshooting-hiera/
  # use 
  # puppet lookup --debug --explain --node puppet.local puppetboard::virtualenv_version
  # to examine puppet's heira lookup
  # OR install gem heira_explain
  # to display lookups in heira
  -> class { 'puppetboard': 
    manage_git        => true,
    manage_virtualenv => true,
  }
  # fix issues with modules not found
  # https://github.com/voxpupuli/puppet-puppetboard/issues/128
#  -> python::pip { 'Flask':
#    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
#  }
#  -> python::pip { 'Flask-WTF':
#    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
#  }
#  -> python::pip { 'WTForms':
#    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
#  }
  # also reinstall wsgi module for python3
  # libapache2-mod-wsgi-py3
  -> python::pip { 'mod_wsgi':
    version    => 'latest',
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }


  # Access Puppetboard through localhost:8000
  class { 'puppetboard::apache::vhost':
    vhost_name => 'localhost',
    port       => 80,
  }
}