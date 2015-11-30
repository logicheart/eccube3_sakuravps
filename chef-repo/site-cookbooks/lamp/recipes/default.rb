#
# Cookbook Name:: lap
# Recipe:: default
#
# Copyright 2015, LogicHeart
#
# All rights reserved - Do Not Redistribute
#

# Disable SELinux
include_recipe "selinux::disabled"

# Local Time
template "/etc/sysconfig/clock" do
  notifies :run, "execute[localtime]", :immediately
end
execute "localtime" do
  command "cp /usr/share/zoneinfo/Japan /etc/localtime"
  action :nothing
end
service "rsyslog" do
  action :restart
end

# Locale
execute "Japanese Support" do
  command 'yum -y groupinstall "Japanese Support"'
  action :run
end
execute "localedef" do
  command 'localedef -f UTF-8 -i ja_JP ja_JP.utf8'
  action :run
end
template "/etc/sysconfig/i18n" do
  notifies :run, "bash[update lang]", :immediately
end
bash "update lang" do
  code ". /etc/sysconfig/i18n"
  action :nothing
end

# iptables
include_recipe "iptables"
iptables_rule 'iptables' do
  action :enable
end

# EPEL repository
include_recipe "yum-epel"

# ClamAV
include_recipe "clamav"

# NTP
include_recipe "ntp"

# Update all packages
execute "yum update" do
  command 'yum -y update --exclude=kernel*'
  action :run
end

# Japanese manual pages
execute "man-page-ja" do
  command 'yum -y install man-pages-ja'
  action :run
end

# bind-utils
execute "bind-utils" do
  command 'yum -y install bind-utils'
  action :run
end

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

# PHP
include_recipe "php"
template "php.ini" do
  path "/etc/php.ini"
  source "php.ini.erb"
  notifies :restart, 'service[httpd]'
end

# MySQL
#include_recipe "mysql::server"
