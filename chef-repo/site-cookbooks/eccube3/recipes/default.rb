#
# Cookbook Name:: eccube3
# Recipe:: default
#
# Copyright 2015, hiroyasu55(LogicHeart)
#
# All rights reserved
#

eccube = node['eccube3']
version = eccube['version']

# ドキュメントルート
document_root = eccube['document_root'] || "#{httpd['docroot_dir']}"
directory document_root do
  not_if { File.directory?(base_dir) }
  owner eccube['user']
  group eccube['group']
  mode 0755
  action :create
  notifies :create, "cookbook_file[zip file]"
end

# EC-CUBE ZIPファイルを配置
eccube_file = "eccube-#{version}.zip"
tempfile = "/tmp/#{eccube_file}"
tempdir = "/tmp/eccube-#{version}"
cookbook_file "zip file" do
  path tempfile
  source eccube_file
  action :create
  notifies :run, "execute[extract zip file]"
end

# EC-CUBEを展開
execute "extract zip file" do
  command "unzip -o -d #{document_root} #{tempfile}"
  action :run
  notifies :run, "execute[change owner]", :immediately
end

execute "change owner" do
  command "chown -R #{eccube['user']}:#{eccube['group']} #{base_dir}"
  action :nothing
  notifies :run, "execute[change mode]", :immediately
end

execute "change mode" do
#  command "chmod -R 0777 #{eccube['document_root']}/"
  command "echo change"
  action :nothing
end

# Apache設定
template "eccube.conf" do
  path "/etc/httpd/conf.d/eccube.conf"
  source "eccube.conf.erb"
  variables({
    :document_root => $document_root,
    :server_name => eccube['server_name']
  })
  notifies :reload, 'service[httpd]'
end

# DB設定
db = node['eccube3']['database']
root_password = db['root_password'] || node['mysql']['server_root_password']
database = db['name']
user = db['user']
password = db['password']
sqlfile = Chef::Config[:file_cache_path] + "/" + Date.today.strftime('%Y%m%d%H%M%S') + "createdb.sql"

template sqlfile do
  source "createdb.sql.erb"
  variables({
    :database => database,
    :user => user,
    :password => password,
  })
  notifies :run, "execute[create database]", :immediately
end

execute "create database" do
  command "mysql -u root -p#{root_password} < #{sqlfile}"
  action :nothing
end
