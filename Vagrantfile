# coding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# original settings
#
PROJECT_NAME = "rails-sample"
PROJECT_FOLDER = "../" + PROJECT_NAME
LOCAL_HOSTNAME = "rails-sample.local"

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.omnibus.chef_version = :latest
  CURRENT_DIR = File.expand_path(File.dirname(__FILE__))

  config.trigger.before [:up, :reload], stdout: true do
    # Delete synced folder
    SYNCED_FOLDER = CURRENT_DIR + "/.vagrant/machines/default/virtualbox/synced_folders"
    if File.exist?(SYNCED_FOLDER) then
      begin
        File.delete(SYNCED_FOLDER)
        info "Delete #{SYNCED_FOLDER}."
      rescue Exception => ex
        warn "Could not delete folder #{SYNCED_FOLDER}."
        warn ex.message
      end
    end
  end

  # CentOS 6.7
  config.vm.box = "bento/centos-6.7"
  config.vm.hostname = "oho.local"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # Synced folder
  config.vm.synced_folder PROJECT_FOLDER, "/var/www/" + PROJECT_NAME,
    :mount_options => ["dmode=777", "fmode=666"], :create => true

  # Chef solo
  config.vm.provision :chef_solo do |chef|
    chef.log_level = :debug
    chef.cookbooks_path = ["chef/cookbooks", "chef/site-cookbooks"]
    chef.roles_path = "chef/roles"
    chef.data_bags_path = "chef/data_bags"

    chef.add_recipe "centos6"
    chef.add_recipe "nginx"

    chef.json = {
      "httpd" => {
        document_root: "/var/www/html",
      },
      "mysql" => {
        server_root_password: "password",
      },
      "yell" => {
        httpd: {
          server_name: "yell.local",
          document_root: "/var/www/yell/Yell/app/html",
        },
        ssl: {
          ssl_dir: "/var/www/yell/ssl",
        }
      },
      "yell-admin" => {
        httpd: {
          server_name: "yell-admin.local",
          document_root: "/var/www/yell/yell-admin/app/html",
        },
        ssl: {
          ssl_dir: "/var/www/yell/ssl",
        }
      },
      "yell-db" => {
        root_password: "password",
        host: "localhost",
        name: "yell_db",
        user: "yell_user",
        password: "yell_user",
      }
    }
  end

end
