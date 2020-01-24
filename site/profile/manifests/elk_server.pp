class profile::elk_server {
  class { 'elk_server':
    remote  => 'https://github.com/mvilain/control-repo',
  }
}
