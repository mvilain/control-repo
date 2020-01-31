class role::master {
  include profile::r10k
  include profile::puppetdb
  # puppetdb when added first correctly creates user and group postgres
  # but it's ordering is wrong when called inside puppetboard
  # which means you can't create a puppetboard server with a puppetdb on another host
#  user {'postgres':
#    ensure  => present,
#    uid     => 112,
#  }->
#  group {'postgres':
#    ensure  => present,
#    gid     => 117,
#  }->

  include profile::puppetboard
  include profile::filebeat_puppetserver
}
