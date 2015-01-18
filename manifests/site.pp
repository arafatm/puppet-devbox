Exec { path => '/usr/bin' }

stage { 'pre':
  before => Stage['main'],
}

$sources = "/etc/apt/sources.list.d"

class node-ppa {
  exec { "add-node-repo":
    command => "curl -sL https://deb.nodesource.com/setup | sudo bash -",
    unless  => "/usr/bin/test -s ${sources}/nodesource.list",
    notify => Exec['apt-update']
  }
  exec { "apt-update":
    command => "/usr/bin/apt-get update",
    refreshonly => true
  }
  package {"nodejs":
    ensure => "installed", 
    require => Exec['apt-update'],
  }
}
class { 'node-ppa':
  stage => 'pre',
}

notify { 'main': }
#class postgresql {
#  package { 'postgresql': ensure => installed }
#  package { 'libpq-dev':  ensure => installed }
#  service { 'postgresql': ensure => running }
#}

#apt::ppa { 'ppa:chris-lea/node.js': }

# ruby/rails
