# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include elk::filebeat
# Filebeat prospectors - expects array of structured data
# [ {
#   "type" => "log",
#   "paths" => [
#      "/var/log/puppetlabs/puppetserver/puppetserver.log.json",
#      "/var/log/puppetlabs/puppetserver/puppetserver-access.log.json",
#    ],
#   "json_keys_under_root" => true
# } ]

class elk::filebeat (
  $prospectors     = [],
  $logstash_server = '127.0.0.1',
  $logstash_port   = '5044',
) {
  include elastic_stack::repo

  package{'filebeat':
    ensure => present,
  }

  service{'filebeat':
    ensure  => running,
    enable  => true,
    require => Package['filebeat'],
  }

# test with 
# filebeat -v -e -d "*"
# filebeat test config -e
  file{'/etc/filebeat/filebeat.yml':
    ensure  => file,
    content => epp('elk/filebeat.yml.epp', {
      prospectors     => $prospectors,
      logstash_server => $logstash_server,
      logstash_port   => $logstash_port,
      }),
    notify  => Service['filebeat'],
  }
}
