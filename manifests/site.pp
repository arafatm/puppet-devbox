Exec { path => '/usr/bin' }

$sources = "/etc/apt/sources.list.d"

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
include node_repo

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
include base

class postgresql {
  package { 'postgresql': ensure => latest }
  package { 'libpq-dev':  ensure => latest }
  service { 'postgresql': ensure => running }
}
class { 'postgresql':
  require => Package[$base],
}
include postgresql

node "vm.furaha.com" {
  $username = "vagrant"
  include dotfiles
}
node default {
  $username = "arafatm"
  include dotfiles
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

#apt::ppa { 'ppa:chris-lea/node.js': }

# ruby/rails
