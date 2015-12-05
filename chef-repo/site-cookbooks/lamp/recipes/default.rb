#
# Cookbook Name:: lamp
# Recipe:: default
#
# Copyright 2015, hiroyasu55(LogicHeart)
#
# All rights reserved
#

# httpd
package "httpd" do
  action :install
end
service "httpd" do
  action [ :enable, :start ]
end
template "/etc/httpd/conf/httpd.conf" do
  notifies :reload, 'service[httpd]'
end

# yum-remi
include_recipe "yum-remi"

# PHP 5.6
node["php"]["packages"].each do |p|
  package p do
    action :install
    options "--enablerepo=remi --enablerepo=remi-php56"
  end
end
template "/etc/php.ini" do
  variables({
    :timezone => node["php"]["timezone"]
  })
  notifies :restart, 'service[httpd]'
end

# MySQL
include_recipe "mysql::server"

# phpMyAdmin
package "phpMyAdmin" do
  action :install
  options "--enablerepo=remi --enablerepo=remi-php56"
end
pma = node["phpMyAdmin"]
execute 'htpasswd' do
  only_if { pma['auth_file'] }
  command "htpasswd -bc #{pma['auth_file']} #{pma['auth_user']} #{pma['auth_password']}"
  action :run
end
template "/etc/httpd/conf.d/phpMyAdmin.conf" do
  variables({
    :auth_file => node["phpMyAdmin"]["auth_file"]
  })
  notifies :reload, 'service[httpd]'
end
