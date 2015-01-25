Exec { path => '/usr/bin' }

$sources = "/etc/apt/sources.list.d"

node "vm" {
  $localuser = "vagrant"

  if $dotuser == undef {
    $dotuser = "arafatm"
  }

  include node_repo
  include base
  include postgresql
  include dotfiles
}

class dotfiles {
  exec { 'dotfiles':
    creates => "/home/$localuser/dotfiles",
    path    => '/bin:/usr/bin',
    command => "su -c 'git clone git@github.com:$dotuser/dotfiles.git /home/$localuser/dotfiles && bash /home/$localuser/dotfiles/setup.dotfiles.sh --force' $localuser",
    require => Class['base'],
  }
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

$base = [ 'curl', 'git', 'tmux', 'vim', 'build-essential', 
'libreadline-dev', 'libssl-dev', 'libcurl4-openssl-dev', 'nodejs']

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


#apt::ppa { 'ppa:chris-lea/node.js': }

# ruby/rails
