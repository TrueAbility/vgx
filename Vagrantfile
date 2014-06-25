# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

VAGRANTFILE_API_VERSION = "2"
VGX_ROOT = File.dirname(__FILE__)
VGX_BOOTSTRAP = ENV['VGX_BOOTSTRAP'] || 'vagrant/bootstrap'
VGX_PREFIX = ENV['VGX_PREFIX'] || ''

# location of box configurations
if Dir.exists?('vagrant/boxes')
  VGX_BOXES = 'vagrant/boxes'
else
  VGX_BOXES = ENV['VGX_BOXES'] || VGX_ROOT + '/boxes'
end

# location of provider configurations
if Dir.exists?('vagrant/providers')
  VGX_PROVIDERS = 'vagrant/providers'
else
  VGX_PROVIDERS = ENV['VGX_PROVIDERS'] || VGX_ROOT + '/providers'
end

boxes = Hash.new()
Dir.foreach("#{VGX_BOXES}") do |name|
  next if name.match(/^\./)
  box_name = "#{VGX_PREFIX}#{name}"
  config = YAML.load_file("#{VGX_BOXES}/#{name}")
  boxes[box_name] = {
    "virtualbox" => config["virtualbox"],
    "rackspace" => config["rackspace"],
    "digital_ocean" => config["digital_ocean"]
  }
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/vagrant"
  config.ssh.username = "root"

  boxes.each do |box_name, box_config|
    vgx_id = "#{ENV['VGX_BOX_PREFIX']}#{box_name}"
    config.vm.define vgx_id do |x|
      # default virtualbox configuration
      x.vm.box_url = box_config['virtualbox']
      x.vm.box = box_name

      x.vm.provider "virtualbox" do |vb, override|
        vb.name = box_name
        vb.gui = false
        override.vm.network "private_network", type: :dhcp, auto_config: false
      end

      if File.exists?('vagrant/scripts/bootstrap')
        x.vm.provision "shell" do |s|
          s.inline = "cd /vagrant && vagrant/scripts/bootstrap"
        end
      end

      # dynamic provider configurations
      Dir.foreach("#{VGX_PROVIDERS}") do |item|
        next if item.match(/^\./)
        eval File.read("#{VGX_PROVIDERS}/#{item}")
      end
    end
  end
end
