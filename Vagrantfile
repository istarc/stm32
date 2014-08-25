# -*- mode: ruby -*-
# vi: set ft=ruby :

###
# Usage
#
#
#
# 1. Build the image 
#
# This is alternative to "1. Pull the image from the repository"
#
# 1.1 Prerequisites:
#
#    vagrant --version
#    Vagrant 1.6.3 # Issues with version < 1.5.0
#    # Install Vagrant by following instructions at https://www.vagrantup.com/downloads.html
#
# 1.2 Install software dependencies
#
#    cd ~
#    # Install VirtualBox
#    sudo apt-get install build-essential virtualbox virtualbox-dkms virtualbox-guest-dkms \
#                         virtualbox-guest-utils virtualbox-guest-x11 virtualbox-qt
#    # Download and install the extension pack https://www.virtualbox.org/wiki/Downloads
#    wget http://download.virtualbox.org/virtualbox/4.3.14/Oracle_VM_VirtualBox_Extension_Pack-4.3.14-95030.vbox-extpack
#    VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.3.14-95030.vbox-extpack
#    # Clone the STM32 repository
#    sudo apt-get install git
#    git clone https://github.com/istarc/stm32.git
#
# 1.3 Deploy the image and provision the STM32F4-Discovery test and build environment
#
#    cd ~/stm32
#    vagrant up
#    vagrant provision
#    # Manually enable ST-Link: Devices -> USB Devices -> STMicroelectronics STM32 STLink
#
# 1.4 Build Existing Projects:
#
#    # Switch to VirtualBox Container
#    cd ~/stm32/
#    make clean
#    make -j4
#
# 1.5 Deploy Existing Project:
#
#    # Switch to VirtualBox Container
#    cd ~/stm32/examples/Template.mbed
#    make clean
#    make -j4
#    # Manually enable ST-Link: Devices -> USB Devices -> STMicroelectronics STM32 STLink
#    sudo make deploy
#
# 1.6 Test Build Existing Projects via Buildbot:
#
#    firefox http://localhost:8010
#    Login U: admin P: admin (Upper right corner)
#    Click: Waterfall -> test-build -> [Use default options] -> Force Build
#    Check: Waterfall -> F5 to Refresh
#
# 1.7 More info:
#  - http://istarc.wordpress.com
#  - https://github.com/istarc/stm32



# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode
    vb.gui = true
 
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024"]

    # Enable DNS
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

    # Enables USB support
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "on"]
  end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file ubuntu/trusty64.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "site.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision :chef_solo do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision :chef_client do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
  #
  
  # Setup environment
  config.vm.provision "shell", inline: "apt-get update -q && apt-get install openssl wget"
  config.vm.provision "shell", inline: "useradd -s /bin/bash -m -d /home/krusty -p $(openssl passwd -1 krusty) krusty"
  config.vm.provision "shell", inline: "sed -Ei 's/adm:x:4:/krusty:x:4:krusty/' /etc/group"
  config.vm.provision "shell", inline: "sed -Ei 's/(\%krusty ALL=\(ALL\) )ALL/\1 NOPASSWD:ALL/' /etc/sudoers"

  # Install GCC ARM Toolchain
  config.vm.provision "shell", inline: "su - krusty -c 'wget https://github.com/istarc/stm32/blob/master/setup-env.sh'"
  config.vm.provision "shell", inline: "su - krusty -c 'setup-env.sh'"

  # Install the GUI
  config.vm.provision "shell", inline: "export DEBIAN_FRONTEND=noninteractive && apt-get update -q && apt-get -y install xubuntu-desktop gksu leafpad synaptic build-essential git eclipse-cdt && apt-get -y remove nautilus gnome-power-manager gnome-screensaver gnome-termina* gnome-pane* gnome-applet* gnome-bluetooth gnome-desktop* gnome-sessio* gnome-user* gnome-shell-common compiz compiz* unity unity* hud zeitgeist zeitgeist* python-zeitgeist libzeitgeist* activity-log-manager-common gnome-control-center gnome-screenshot overlay-scrollba* && apt-get -y install xubuntu-community-wallpapers && apt-get autoremove"

end
