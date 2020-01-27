class profile::puppetboard {
  # setup apache to serve the board up
  class { 'apache': }
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