# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

VAGRANTFILE_API_VERSION = "2"
VGX_ROOT = File.dirname(__FILE__)

boxes = Hash.new()
Dir.foreach("#{VGX_ROOT}/boxes") do |box_name|
  next if box_name.match(/^\./)
  config = YAML.load_file("#{VGX_ROOT}/boxes/#{box_name}")
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
    vgx_id = "#{ENV['PREFIX']}#{box_name}"
    config.vm.define vgx_id do |x|
      x.vm.box_url = box_config['virtualbox']
      x.vm.box = box_name

      if ENV['RUN']
        x.vm.provision "shell" do |s|
          s.inline = "cd /vagrant && RUN=\"#{ENV['RUN']}\""
        end
      end

      x.vm.provider "virtualbox" do |vb, override|
        vb.name = box_name
        vb.gui = false
        override.vm.network "private_network", type: :dhcp
      end

      Dir.foreach("#{VGX_ROOT}/providers") do |item|
        next if item.match(/^\./)
        eval File.read("#{VGX_ROOT}/providers/#{item}")
      end
    end
  end
end
