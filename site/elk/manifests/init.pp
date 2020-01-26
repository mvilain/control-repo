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
    ensure  => present,
    #source  => 'puppet:///modules/elk/etc-default-logstash',
    require => Package['filebeat'],
  }
  -> class {'logstash':
    ensure      => present,
    package_url => 'https://artifacts.elastic.co/downloads/logstash/logstash-6.8.6.deb',
  }
  -> logstash::plugin{'logstash-input-beats':
  }
  -> logstash::configfile{'beats':
    source  => 'puppet:///modules/elk/beats.conf',
  }

# V7 elastic search doesn't work here, so install 6.8.6
  include ::java

  class { 'elasticsearch':
    ensure      => present,
    status      => enabled,
    jvm_options => ['-Xms256m','-Xmx256m'],
    package_url =>     package_url => 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.6.deb',
    require     => Package['java'],
  }
  -> elasticsearch::instance { 'es-01': }

  class {'kibana':
    ensure => '6.8.6',
    config => {
      'server.host' => '0.0.0.0',
    }
  }

  include elk::filebeat

}
