#
# Cookbook Name:: sakuravps
# Recipe:: createuser
#
# Copyright 2015, hiroyasu55(LogicHeart)
#
# All rights reserved
#

# wheelグループの作成
group "wheel" do
  action :create
end

# data bagsよりユーザーを作成
data_ids = data_bag('users')

# 管理者ユーザー作成
user_name node["admin_user"]["name"]
user_name node["admin_user"]["password"]
u = data_bag_item('users', id)
user u['username'] do
  password u['password']
  supports :manage_home => true, :non_unique => false
    group u['group']
    action [:create]
  end

# ssh公開鍵配置用のディレクトリ作成
  directory "/home/#{id}/.ssh" do
    owner u["id"]
    group u["id"]
    mode 0700
    action :create
  end

  # ssh公開鍵の配置
  file "/home/#{id}/.ssh/authorized_keys" do
    owner u["id"]
    mode 0600
    content u["key"]
    action :create_if_missing
  end
end
