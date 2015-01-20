Exec { path => '/usr/bin' }


class postgresql {
  package { 'postgresql': ensure => installed }
  package { 'libpq-dev':  ensure => installed }
  service { 'postgresql': ensure => running }
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
