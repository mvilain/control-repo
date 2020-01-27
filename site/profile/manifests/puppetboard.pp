class profile::puppetboard {
  # setup apache to serve the board up
  class { 'apache': }
  class { 'apache::mod::wsgi': }

# https://github.com/voxpupuli/puppetboard/issues/527
  class { 'puppetboard': 
    manage_git        => true,
    manage_virtualenv => true,
    revision          => 'v1.0.0',
  }

  # Access Puppetboard through pboard.example.com
  class { 'puppetboard::apache::vhost':
    vhost_name => 'localhost',
    port       => 80,
  }
}