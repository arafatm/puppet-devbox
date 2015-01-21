#!/usr/bin/env bash 

export DEBIAN_FRONTEND=noninteractive 

# Install Puppet Source
if [ ! -f /etc/apt/sources.list.d/puppetlabs.list ]; then
  wget http://apt.puppetlabs.com/puppetlabs-release-$(lsb_release -sc).deb
  dpkg -i puppetlabs-release-$(lsb_release -sc).deb
fi

apt-get update

mkdir -p /etc/puppet/modules;

# Install Puppet Modules

install_module() {
  folder=`echo $1 | sed s/.*-//`
  if [ ! -d /etc/puppet/modules/$folder ]; then
    puppet module install $1
  fi
}

install_module puppetlabs-stdlib
install_module puppetlabs-apt
install_module puppetlabs-nodejs
install_module puppetlabs-postgresql

#USER=$1
#RUBY=$2
#
#msg() { echo "*" echo "*"
#  echo "*****************************************************************"
#  echo "*****************************************************************"
#  echo "$1"
#}
#
#apt() {
#  sudo apt-get install -y --force-yes $1
#}
#
#apt_3rd_party() {
#  # node.js  repo
#  if [ ! -f /etc/apt/sources.list.d/chris-lea*.list ]; then 
#    msg "adding node.js repo"
#    sudo add-apt-repository ppa:chris-lea/node.js
#  fi
#
#  # postgresql repo
#  if [ ! -f /etc/apt/sources.list.d/pgdg.list ]; then 
#    msg "adding postgresql repo"
#    sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ \
#      $(lsb_release -sc)-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
#    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | \
#      sudo apt-key add -
#  fi
#}
#
#apt_upgrade() {
#  msg "APT update & upgrade"
#
#  sudo ntpdate ntp.ubuntu.com
#
#  sudo apt-get update
#  sudo apt-get dist-upgrade -q -y --force-yes 
#}
#
#apt_core() {
#
#  pkgs="curl git screen tmux vim zerofree"
#  pkgs="$pkgs zlib1g-dev build-essential libssl-dev libreadline-dev"
#  pkgs="$pkgs libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev" 
#  pkgs="$pkgs libcurl4-openssl-dev python-software-properties nodejs"
#  pkgs="$pkgs imagemagick libmagickwand-dev"
#
#  msg "install pkgs"
#  echo "$pkgs"
#  apt "$pkgs"
#}
#
#postgres() {
#  msg "postgresql"
#  apt "postgresql-9.3 libpq-dev"
#  sudo -u postgres createuser vagrant -s
#}
#
#apt_clean() {
#  msg "APT clean"
#  sudo apt-get -y autoremove
#  sudo apt-get -y clean
#  sudo apt-get autoclean -y
#}
#
#install_chruby() {
#
#  if [ ! `which ruby-install` ]; then
#    msg "installing ruby-install"
#    mkdir $HOME/tmp 
#    cd $HOME/tmp
#    # Install Ruby. Skip if you've already done this.
#    wget -O ruby-install.tar.gz \
#      https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
#    tar -xzvf ruby-install.tar.gz
#    cd ruby-install-*
#    make update
#    sudo make install
#  fi
#
#  if [ ! `which chruby-exec` ]; then
#    msg "installing chruby"
#    cd $HOME/tmp
#    wget -O chruby.tar.gz \
#      https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
#    tar -xzvf chruby.tar.gz
#    cd chruby-*
#    sudo make install
#    echo "source /usr/local/share/chruby/chruby.sh" >> $HOME/.bashrc
#    echo "
#if [[ -f ./.ruby_version ]]; then
#  chruby \`cat ./.ruby_version\`
#else
#  chruby \`chruby | head -n 1 | cut -c4-\`
#fi" >> $HOME/.bashrc
#
#  fi
#
#  if [[ ! -d "$HOME/.rubies" ]]; then
#    msg "ruby install"
#    if [[ -f /vagrant/.ruby_version ]]; then
#      RUBY=`cat /vagrant/.ruby_version`
#      ruby-install ruby "${RUBY#*-}" 
#    else
#      ruby-install ruby $RUBY 
#    fi
#    source /usr/local/share/chruby/chruby.sh && chruby `chruby`
#
#    msg "bundle install"
#    which bundle || gem install bundler
#    cd /vagrant
#    bundle install
#  fi
#}
#
#install_rbenv() {
#  if [ ! `which rbenv` ]; then
#    msg "installing rbenv"
#    git clone git://github.com/sstephenson/rbenv.git $HOME/.rbenv
#
#    msg "rbenv: ruby-build"
#    git clone git://github.com/sstephenson/ruby-build.git \
#      $HOME/.rbenv/plugins/ruby-build
#
#    msg "rbenv: rbenv-gem-rehash"
#    git clone https://github.com/sstephenson/rbenv-gem-rehash.git \
#      $HOME/.rbenv/plugins/rbenv-gem-rehash
#  else
#    msg "updating ruby version"
#  fi
#
#  msg "latest ruby"
#
#  rbenv=$HOME/.rbenv/bin/rbenv
#
#  #LATEST=`$rbenv install -l | grep '^\s*2.1.*' | grep -v dev | sort | tail -n 1`
#  LATEST='2.1.5'
#
#  if [[ ! $(ruby -v) =~ "ruby $LATEST" ]]; then 
#    CONFIGURE_OPTS="--disable-install-doc" $rbenv install -v $LATEST 
#    $rbenv global  $LATEST
#    $rbenv rehash
#  else
#    echo "ruby $LATEST already installed"
#  fi
#}
#
#install_dotfiles() {
#  msg "Installing $USER dotfiles"
#  if [[ ! -d $HOME/dotfiles ]]; then 
#    msg "installing dotfiles" 
#    git clone https://github.com/$USER/dotfiles.git $HOME/dotfiles
#    bash $HOME/dotfiles/setup.dotfiles.sh
#  else
#    msg "updating dotfiles" 
#    cd $HOME/dotfiles
#    git pull
#  fi
#}
#
#apt_3rd_party
#apt_upgrade
#apt_core
#postgres
#apt_clean
#
#install_chruby
#install_dotfiles
