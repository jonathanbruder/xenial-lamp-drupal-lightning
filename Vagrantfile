# -*- mode: ruby -*-
# vi: set ft=ruby :
DS = File::SEPARATOR
projectPath = File.dirname(__FILE__)
baseName = File.basename(projectPath)
modDir = "/home/vagrant/"+baseName+"/node_modules"
mountDir = "/var/www/"+baseName
shellEnv = {
   "VAGRANT" => "/home/vagrant",
   "VAGRANT_PROJECT_NAME" => baseName,
   "VAGRANT_MOD_DIR" => modDir,
   "VAGRANT_MOUNT_DIR" => mountDir
   "VAGRANT_APP_DIR" => baseName,
   "VAGRANT_DEV_MYP" => baseName,
   "VAGRANT_DB" => baseName,
   "VAGRANT_TIMEZONE" => "America/Chicago",
   "VAGRANT_ENVIRONMENT" => "development"
}

Vagrant.configure("2") do |config|
	config.vm.provider "virtualbox" do |v|
  		v.memory = 2048
  		v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
        v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  		v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/var_www", "1"]
	end

	config.vm.define :skunkworks do |skunkworks|
        skunkworks.vm.box = "ubuntu/xenial64"


		skunkworks.vm.hostname = "skunkworks"

		skunkworks.vm.network :forwarded_port, host: 14000, guest: 13000
		skunkworks.vm.network :forwarded_port, host: 12010, guest: 10010
		skunkworks.vm.network :forwarded_port, host: 12011, guest: 10011
		skunkworks.vm.network :forwarded_port, host: 12080, guest: 80
		skunkworks.vm.network :forwarded_port, host: 14306, guest: 3306
		
		skunkworks.vm.synced_folder ".", "/vagrant", disabled: true
		skunkworks.vm.synced_folder projectPath, mountDir, group: "www-data", mount_options: ['dmode=0775','fmode=0775']
	end


    config.vm.provision :shell do |shell|
        shell.privileged = true;
        shell.path = "provisioning/services.sh"
        shell.env = shellEnv
    end

end
