#
# Cookbook Name:: sakuravps
# Recipe:: createuser
#
# Copyright 2015, hiroyasu55(LogicHeart)
#
# All rights reserved
#

include_recipe "sudo"

data_ids = data_bag('users')
data_ids.each do |id|
  u = data_bag_item('users', id)

  # グループ作成
  u['group'] = u['name'] if !u['group']
  group u['group'] do
    action :create
  end

  # ユーザー作成
  user u['name'] do
    uid u['uid'] if u['uid']
    group u['group']
    shell u['shell'] if u['shell']
    home u['home'] if u['home']
    comment u['comment'] if u['comment']
    password u['password']
    supports :manage_home => true, :non_unique => false
    action :create
  end

  # SSHディレクトリ作成
  ssh_dir = (u['home'] || "/home/#{u['name']}") + "/.ssh"
  directory ssh_dir do
    only_if { !File.directory?(ssh_dir) }
    owner u["name"]
    group u["group"] || u['name']
    mode 0700
    action :create
  end

  # SSH公開鍵配置
  file "#{ssh_dir}/authorized_keys" do
    only_if { u['ssh_public_key'] }
    content "#{u['ssh_public_key']}"
    owner u['name']
    group u['group']
    mode '0600'
    action :create
  end

  # wheelグループに所属
  group "wheel" do
    only_if { u['wheel'] }
    members [ u['name'] ]
    action :modify
    append true
  end

end
