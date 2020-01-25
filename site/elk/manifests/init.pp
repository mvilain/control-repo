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


  class { 'elastic_stack::repo':
    version => 6,
  }

  include ::java
  class { 'elasticsearch':
    jvm_options => ['-Xms256m','-Xmx256m'],
    status      => enabled,
    ensure      => present,
#    version     => '6.8.4',
  }
  elasticsearch::instance { 'es-01': }


  class {'kibana':
    config => {
      'server.host' => '0.0.0.0',
    }
  }

  include elk::filebeat
}
