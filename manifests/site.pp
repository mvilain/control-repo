node puppet.local {
  include role::master
#  file {'/etc/secret_password.txt':
#  	ensure  => file,
#	content => lookup('secret_password'),
#	owner   => 'root',
#	group   => 'root',
#	mode    => '0600',

  }

}
