class profile::puppetboard {

  # independent but needed to serve puppetboard web site
  class { 'apache': }
  class { 'apache::mod::wsgi': }

  # fix issues with modules not found
  # https://github.com/voxpupuli/puppetboard/issues/527
  class { 'python':
    version    => '3.6',
    pip        => 'present',
    dev        => 'present',
    virtualenv => 'present',
#    gunicorn   => 'present',
  }
  -> python::pip { 'packaging' : 
    ensure => '19.0', 
    pkgname => 'packaging', 
  }
  -> python::pip { 'Flask':
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }
  -> python::pip { 'Flask-WTF':
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }
  -> python::pip { 'WTForms':
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }
  -> python::pip { 'pypuppetdb':
    virtualenv => '/srv/puppetboard/virtenv-puppetboard',
  }

  # puppetboard 1.1 requires python 3.[678]
  # fix issues with modules not found
  # https://github.com/voxpupuli/puppet-puppetboard/issues/128
  # this file is needed to create the virtual environment for puppetboard
  file{'/srv/puppetboard/puppetboard/requirements.txt':
    ensure => present,
  }
  -> class { 'puppetboard': 
    manage_git        => true,
    manage_virtualenv => true,
    #revision          => 'v1.1.0', # repo tag
  }

  # Access Puppetboard through pboard.example.com
  class { 'puppetboard::apache::vhost':
    vhost_name => 'localhost',
    port       => 80,
  }
}