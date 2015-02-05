# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. 
# Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

unless Vagrant.has_plugin?("vagrant-vbguest")
  system("vagrant plugin install vagrant-vbguest")
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Either use i386 or amd64 versions
  #config.vm.box       = 'puppetlabs/debian-7.6-32-nocm'
  config.vm.box       = 'ubuntu/trusty32'

  config.vm.hostname  = 'vm.furaha.com'
  config.ssh.forward_agent = true

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end


  config.vm.provision :shell, :path => "./bootstrap.sh" 

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "site.pp"
    puppet.options        = "--verbose"
  end
end
