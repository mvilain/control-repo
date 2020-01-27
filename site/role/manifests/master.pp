class role::master {
  include profile::r10k
  include profile::puppetdb
  include profile::puppetboard
}
