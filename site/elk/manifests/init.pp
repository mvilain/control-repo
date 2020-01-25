# elk
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include elk

class elk {

  include ::java

  file {'/etc/default/logstash':
    ensure => present,
    source => 'puppet:///modules/elk/etc-default-logstash',
  }
  -> class {'logstash':
    ensure      => present,
    package_url => 'https://artifacts.elastic.co/downloads/logstash/logstash-6.2.3.deb',
  }
  -> logstash::plugin{'logstash-input-beats':
  }
  -> logstash::configfile{'beats':
    source  => 'puppet:///modules/elk/beats.conf',
    require => Package['filebeats'],
  }

# V7 elastic search doesn't work here, so install 6.2.4
  class { 'elasticsearch':
    ensure      => present,
    status      => enabled,
    jvm_options => ['-Xms256m','-Xmx256m'],
    package_url => 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.2.4.deb',
    require     => Package['java'],
  }
  -> elasticsearch::instance { 'es-01': }

  class {'kibana':
#    package_url => 'https://artifacts.elastic.co/downloads/kibana/kibana-6.4.0-amd64.deb',
    ensure => '6.4.0',
    config => {
      'server.host' => '0.0.0.0',
    }
  }

  include elk::filebeat
}
