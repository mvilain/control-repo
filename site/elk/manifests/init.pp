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
  class { 'elastic_stack::repo':
    version    => 6,
  }

# create an empty version of this so logstash install doesn't complain
  file {'/etc/default/logstash':
    ensure  => present,
  }
  -> class {'logstash':
    ensure => present,
    status => enabled,
  }
  -> logstash::plugin{'logstash-input-beats':
  }
  -> logstash::configfile{'beats':
    source  => 'puppet:///modules/elk/beats.conf',
  }
  include elk::filebeat

# elasticsearch controlled by specific instance names
  class { 'elasticsearch':
    jvm_options => ['-Xms256m','-Xmx256m'],
    require     => Package['java'],
  }
  -> elasticsearch::instance { 'es-01':
    ensure => present,
    status => enabled,
  }

  class {'kibana':
    ensure => present,
    config => {
      'server.host' => '0.0.0.0',
    }
  }

}
