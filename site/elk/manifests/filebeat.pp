# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include elk::filebeat
class elk::filebeat (
  $logstash_server = '127.0.0.1',
  $logstash_port   = '5044',
) {
  include elastic_stack::repo

  package{'filebeat':
    ensure => present,
  }

  service{'filebeat':
    ensure  => 'running',
    enable  => true,
    require => Package['filebeat'],
  }

  file{'/etc/filebeat/filebeat.yml':
    ensure => file,
    content => epp('elk/filebeat.yml.epp', {
      logstash_server => $logstash_server,
      logstash_port   => $logstash_port,
      })
    )
  }
}
