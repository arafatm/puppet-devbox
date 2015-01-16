Exec { path => '/usr/bin' }

stage { 'pre':
  before => Stage['main'],
}

class apt_updates {
  exec { 'apt-get update':
    path => '/usr/bin',
  }
}

class { 'apt_updates':
  stage => 'pre'
} 

class postgresql {
  package { 'postgresql': ensure => installed }
  package { 'libpq-dev':  ensure => installed }
  service { 'postgresql': ensure => running }
}

#apt::ppa { 'ppa:chris-lea/node.js': }

# ruby/rails
