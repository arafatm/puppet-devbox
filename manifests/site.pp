stage { 'preinstall':
  before => Stage['main']
}

class apt_get_update {
  exec { 'apt_update': 
  command => '/usr/bin/apt-get update', 
  }
}

class { 'apt_get_update':
  stage => preinstall
} 

class postgresql {
  package { 'postgresql':  ensure => installed }
  service { 'postgresql': ensure => running }
}

#apt::ppa { 'ppa:chris-lea/node.js': }

# ruby/rails
