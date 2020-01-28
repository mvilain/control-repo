class profile::puppetboard {

  # independent but needed to serve puppetboard web site
  class { 'apache': }
  class { 'apache::mod::wsgi': }

  # module puppetboard 1.1 requires python 3.[678]
  # fix issues with modules not found
  # but the virtual environment crated by puppetboard installs python 2.7
  # https://github.com/voxpupuli/puppet-puppetboard/issues/128
  # this file is needed to create the virtual environment for puppetboard
  class { 'puppetboard': 
    manage_git        => true,
    manage_virtualenv => true,
  }

  # Access Puppetboard through pboard.example.com
  class { 'puppetboard::apache::vhost':
    vhost_name => 'localhost',
    port       => 80,
  }
}