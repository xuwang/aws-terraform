# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-server-vivid"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/vivid/current/vivid-server-cloudimg-amd64-vagrant-disk1.box"

  # app ports
  # config.vm.network :forwarded_port, guest: 8080, host: 80, auto_correct: true
  # config.vm.network :forwarded_port, guest: 8443, host: 443, auto_correct: true
  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".", "/home/vagrant/aws-terraform"
  config.vm.synced_folder "~/.aws", "/home/vagrant/.aws"
  config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"

  # Get rid of stdin: not tty error
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
    vb.customize [
      "modifyvm", :id,
      "--memory", "2048"
    ]
  end
   config.vm.provision "shell", inline: $install_tools
end

$install_tools = <<SCRIPT
echo installing jq, unzip, and pip ...
export DEBIAN_FRONTEND=noninteractive
apt-get update; apt-get install -y python-pip jq unzip git
echo installing awscli ...
pip install --upgrade awscli s3cmd
echo installing terraform ...
mkdir -p /opt/terraform
pushd /opt/terraform
wget -nc -q https://dl.bintray.com/mitchellh/terraform/terraform_0.6.3_linux_amd64.zip
unzip -q terraform_0.6.3_linux_amd64.zip
popd
mkdir -p /etc/profile.d
echo PATH=$PATH:/opt/terraform > /etc/profile.d/terraform.sh
aws --version
jq --version
/opt/terraform/terraform --version
SCRIPT
