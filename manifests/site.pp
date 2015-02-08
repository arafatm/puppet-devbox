Exec { path => ['/bin', '/usr/bin'] }

$sources = "/etc/apt/sources.list.d"

node "vm" {

  include node_repo
  include base
  include install_postgresql
  include install_rbenv

  # This isn't reliable. See note in class dotfiles
  if $localuser == undef {
    $localuser = "vagrant"
  }

  if $dotuser == undef {
    $dotuser = "arafatm"
  }
  #include dotfiles


}

class install_rbenv { 
  class { 'rbenv': latest => true, }
  rbenv::plugin {'sstephenson/ruby-build': latest => true }
  rbenv::plugin {'sstephenson/rbenv-gem-rehash': latest => true }
  rbenv::build {'2.1.5': }
}

class install_postgresql {
  class { 'postgresql::server':
    ip_mask_deny_postgres_user  => '0.0.0.0/32',
    ip_mask_allow_all_users     => '0.0.0.0/0',
    require                     => Class['base'],
    package_ensure              => latest,
  }
  # you would think this would work but you would be wrong.
  # See https://github.com/nesi/puppet-postgresql/pull/1/files
  # class { 'postgresql::lib::devel':
  #   package_ensure  =>  latest,
  # }
  $pgpackages   = $operatingsystem? {
    Ubuntu  => ["libpq-dev", "postgresql-server-dev-9.3"],
    default => 'postgresql-devel',
  }
  package { $pgpackages: 
    ensure => latest,
  }

  class { 'postgresql::server::contrib':
    package_ensure  => latest,
  }

  exec { 'pgcrypto':
    command => "sudo -u postgres psql template1 -c 'create extension pgcrypto'",
    #command => "echo 'yermom'",
    unless => "sudo -u postgres psql template1 -c '\\dx' | grep pgcrypto",
    require => Class['postgresql::server::contrib'],
  }

  postgresql::server::role { 'rails':
    password_hash => postgresql_password('rails', 'railspass'),
    createdb      => true,
  }
}

class dotfiles {
  # This doesn't work in vagrant unless you have ssh-agent
  # on the host. On Windows, you need to run pagaent
  exec { 'ssh know github':
    command => 'ssh-keyscan github.com',
    user    => 'vagrant',
    require => Class["base"], 
  }

  vcsrepo { "/home/$localuser/dotfiles":
    ensure   => latest,
    provider => git,
    source   => "git@github.com:$dotuser/dotfiles.git",
    user     => "$localuser",
    owner    => "$localuser",
    group    => "$localuser",
    require  => Exec['ssh know github'],
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

$base = [ 'curl', 'tmux', 'vim' ]
#$base = [ 'curl', 'tmux', 'vim', 'build-essential', 'libreadline-dev', 'libssl-dev', 'libcurl4-openssl-dev']

class base {
  package { $base:
    ensure => latest,
  }
}


#apt::ppa { 'ppa:chris-lea/node.js': }

# ruby/rails
