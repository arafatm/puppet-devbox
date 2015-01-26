Exec { path => '/usr/bin' }

$sources = "/etc/apt/sources.list.d"

node "vm" {
  if $localuser == undef {
    $localuser = "vagrant"
  }

  if $dotuser == undef {
    $dotuser = "arafatm"
  }

  include node_repo
  include base
  #include postgresql
  include dotfiles

  class { 'postgresql::server':
    ip_mask_deny_postgres_user  => '0.0.0.0/32',
    require                    => Class['base'],
    package_ensure  => latest,
  }
  class { 'postgresql::server::contrib':
    package_ensure  => latest,
  }
  exec { 'pgcrypto':
    command => "sudo -u postgres psql template1 -c 'create extension pgcrypto'",
    unless => "sudo -u postgres psql template1 -c '\\dx' | grep -c pgcrypto'",
    require => Class['postgresql::server::contrib'],
  }

  postgresql::server::db { 'mydatabasename':
    user     => 'mydatabaseuser',
    password => postgresql_password('mydatabaseuser', 'mypassword'),
  }
}

class dotfiles {
  exec { 'dotfiles':
    creates => "/home/$localuser/dotfiles",
    path    => '/bin:/usr/bin',
    command => "su -c 'git clone https://github.com/$dotuser/dotfiles.git /home/$localuser/dotfiles && bash /home/$localuser/dotfiles/setup.dotfiles.sh --force' - $localuser",
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
  package { 'nodejs':
    ensure => latest,
    require => Exec['apt_update']
  }
}

$base = [ 'curl', 'git', 'tmux', 'vim', 'build-essential', 'libreadline-dev',
'libssl-dev', 'libcurl4-openssl-dev']

class base {
  package { $base:
    ensure => latest,
  }
}


#apt::ppa { 'ppa:chris-lea/node.js': }

# ruby/rails
