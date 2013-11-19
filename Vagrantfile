require "yaml"

# Load up our vagrant config files -- vagrantconfig.yaml first
_config = YAML.load(File.open(File.join(File.dirname(__FILE__),
                    "vagrantconfig.yaml"), File::RDONLY).read)

# Local-specific/not-git-managed config -- vagrantconfig_local.yaml
begin
    _config.merge!(YAML.load(File.open(File.join(File.dirname(__FILE__),
                   "vagrantconfig_local.yaml"), File::RDONLY).read))
rescue Errno::ENOENT # No vagrantconfig_local.yaml found -- that's OK; just
                     # use the defaults.
end

CONF = _config
MOUNT_POINT = '/home/vagrant/project'

Vagrant::Config.run do |config|
    # nfs needs to be explicitly enabled to run.
    if CONF['nfs'] == false or RUBY_PLATFORM =~ /mswin(32|64)/
        config.vm.share_folder("vagrant-root", MOUNT_POINT, ".")
    else
        config.vm.share_folder("vagrant-root", MOUNT_POINT, ".", :nfs => true)
    end

    # Add to /etc/hosts: 33.33.33.24 dev.example.com
    #config.vm.network :hostonly, "33.33.33.24"

    #config.vm.provision :puppet do |puppet|
    #    puppet.manifests_path = "puppet/manifests"
    #    puppet.manifest_file  = "vagrant.pp"
    #end
    config.vm.define "ubuntu", primary: true do |ubuntu|
    	ubuntu.vm.box = "precise64"
    	#ubuntu.vm.box_url = "http://files.vagrantup.com/precise64.box"
    	ubuntu.vm.box_url = "http://it.sofhouse.net/vagrantboxes/precise64.box"
	ubuntu.vm.forward_port 8000, 8001
	ubuntu.vm.forward_port 80, 8080
	ubuntu.vm.forward_port 90, 8090
	ubuntu.vm.forward_port 443, 8443
    end

    config.vm.define "centos" do |centos|
    	centos.vm.box = "centos"
    	centos.vm.box_url = "http://it.sofhouse.net/vagrantboxes/centos-64-x64-vbox4210.box"
    	centos.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210.box"
    	#centos.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v0.1.0/centos64-x86_64-20131030.box"
    	# Increase vagrant's patience during hang-y CentOS bootup
    	# see: https://github.com/jedi4ever/veewee/issues/14
    	centos.ssh.max_tries = 50
    	centos.ssh.timeout   = 300
	centos.vm.forward_port 8000, 9001
	centos.vm.forward_port 80, 9080
	centos.vm.forward_port 90, 9090
	centos.vm.forward_port 443, 9443
    end

end
