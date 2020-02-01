class profile::puppetboard {

  # independent but needed to serve puppetboard web site
  class { 'apache': }
  #installs for system python (e.g. python2)
  class { 'apache::mod::wsgi': }
#  -> package{'libapache2-mod-wsgi-py3': 
#    ensure => present, 
#  }
  # https://stackoverflow.com/questions/45364577/bin-sh-apxs-command-not-found-when-installing-mod-wsgi
  -> package{'apache2-dev': 
    ensure => present, 
  }
  # https://www.reddit.com/r/learnpython/comments/5mba64/why_cant_i_pip_this_library_ubuntu/
  -> package{'python3-dev': 
    ensure => present, 
  }
  # also reinstall wsgi module for python3 (apache2-dev+python3-dev required)
  # libapache2-mod-wsgi-py3
  -> python::pip { 'mod_wsgi':
    ensure     => present,
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }
  # this really didn't help, sooo, installing 2to3 conversion tool
  -> package{'2to3':
    ensure => present,
  }
  
  # this should be decleared by python module but it's not created in the right order
  # which means you have to run puppet apply twice
#  file{'/srv/puppetboard/virtenv-puppetboard':
#    ensure  => directory,
#  }

  # puppetdb needs postgresql server installed
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
  #
  # note: the tag used here is only viewable if you git clone the repo. 
  # The documentation doesn't match the valid values for this option.
  -> class { 'puppetboard': 
    manage_git        => true,
    manage_virtualenv => true,
    #revision          => 'v1.0.0',
  }
  # fix issues with modules not found
  # https://github.com/voxpupuli/puppet-puppetboard/issues/128
  -> python::pip { 'Flask':
    ensure     => present,
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }
  -> python::pip { 'Flask-WTF':
    ensure     => present,
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }
  -> python::pip { 'WTForms':
    ensure     => present,
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }

  # Access Puppetboard through localhost:8000
  class { 'puppetboard::apache::vhost':
    vhost_name => 'localhost',
    port       => 80,
  }
}