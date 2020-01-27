class profile::puppetboard {

  # fix issues with modules not found
  # https://github.com/voxpupuli/puppet-puppetboard/issues/128

  # this file is needed to create the virtual environment for puppetboard
  file{'/srv/puppetboard/puppetboard/requirements.txt':
    ensure => present,
  }
  -> class { 'apache': }
  -> class { 'apache::mod::wsgi': }

# https://github.com/voxpupuli/puppetboard/issues/527
  class { 'puppetboard': 
    manage_git        => true,
    manage_virtualenv => true,
    revision          => 'v1.0.0', # repo tag
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

  # Access Puppetboard through pboard.example.com
  class { 'puppetboard::apache::vhost':
    vhost_name => 'localhost',
    port       => 80,
  }
}