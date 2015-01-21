Exec { path => '/usr/bin' }

$sources = "/etc/apt/sources.list.d"

node "vm" {
  include node_repo
  include base
  include postgresql
}

class node_repo {
  exec { "add_node_repo":
    command => "curl -sL https://deb.nodesource.com/setup | sudo bash -",
    unless  => "/usr/bin/test -s ${sources}/nodesource.list",
    notify => Exec['apt_update'],
  }
  exec { "apt_update":
    command => "/usr/bin/apt-get update",
    refreshonly => true,
  }
}

$base = [ 'curl', 'git', 'tmux', 'vim', 'zlib1g-dev', 'build-essential',
'libssl-dev', 'libreadline-dev', 'libyaml-dev', 'libsqlite3-dev', 'sqlite3',
'libxml2-dev', 'libxslt1-dev', 'libcurl4-openssl-dev',
'python-software-properties', 'imagemagick', 'libmagickwand-dev', 'nodejs']

class base {
  package { $base:
    ensure => latest,
    require => Exec['add_node_repo'],
  }
}

class postgresql {
  package { 'postgresql':
    ensure => latest,
  }
  package { 'libpq-dev':
    ensure => latest, 
    require => Package['postgresql'], 
  }
  service { 'postgresql':
    ensure => running, 
    require => Package['libpq-dev'], 
  }
}
class { 'postgresql':
  require => Package[$base],
}

class dotfiles {
  exec { 'dotfiles':
    creates => '/home/vagrant/dotfiles',
    path    => '/bin:/usr/bin',
    command => "su -c 'git clone https://github.com/arafatm/dotfiles.git
    /home/$username/dotfiles && bash /home/$username/dotfiles/setup.dotfiles.sh
    --force' $username",

    require => Class['base']
  }
}


if $::foo != undef {
  notify { "$::foo": }
}
else {
  notify { "no foo for you": }
}

notify { "$::fqdn": }
#apt::ppa { 'ppa:chris-lea/node.js': }

# ruby/rails
