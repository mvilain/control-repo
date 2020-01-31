class profile::puppetdb{
  # Configure puppetdb and its underlying database
  # use 
  # puppet lookup --debug --explain --node puppet.local puppetboard::virtualenv_version
  # to examine puppet's heira lookup
  class { 'puppetdb': }
  # Configure the Puppet master to use puppetdb
  class { 'puppetdb::master::config': }
}