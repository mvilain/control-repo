
class puppetboard {
  # setup apache to serve the board up
  class { 'apache':
    ensure => present,
    status => enabled,
  }
  class { 'apache::mod::wsgi': }

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