class profile::puppetboard {

  # independent but needed to serve puppetboard web site
  class { 'apache': }
  class { 'apache::mod::wsgi': }

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
  class { 'puppetboard': 
    manage_git        => true,
    manage_virtualenv => true,
  }
  # fix issues with modules not found
  # https://github.com/voxpupuli/puppet-puppetboard/issues/128
  -> python::pip { 'Flask':
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }
  -> python::pip { 'Flask-WTF':
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }
  -> python::pip { 'WTForms':
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }

  # Access Puppetboard through localhost:8000
  class { 'puppetboard::apache::vhost':
    vhost_name => 'localhost',
    port       => 80,
  }
}