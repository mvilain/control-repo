# elk
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include elk

class elk {
  class {'logstash':}
  logstash::plugin {'logstash-input-beats':}
  logstash::configfile{'beats':
    source => 'puppet:///modules/elk/beats.conf',
  }


  include ::java
  class { 'elastic_stack::repo':
    version => 6,
  }

  class { 'elasticsearch':
    jvm_options  => ['-Xms256m','-Xmx256m'],
    status       => enabled,
    ensure       => present,
    version      => '6.4.2',
  }
  elasticsearch::instance { 'es-01': }


  class {'kibana': 
    config => {
      'server.host' => '0.0.0.0'
    }
  }

  include elk::filebeat
}
