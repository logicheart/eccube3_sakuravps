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

# ユーザー作成
ids = data_bag('users')
ids.each do |id|
  u = data_bag_item('users', id)
  user u['name'] do
    uid u['id']
    group u['group'] if u['group']
    shell u['shell'] if u['shell']
    home u['home'] if u['home']
    comment u['comment'] if u['comment']
    password u['password'] || "$1$eCoTPhGl$SgbuqABM1.cUO4uh543ry0"
    supports :manage_home => true, :non_unique => false
    action :create
  end

  # SSHディレクトリ作成
  sshdir = (u['home'] || "/home/#{u['name']}") + "/.ssh"
  directory sshdir do
    only_if { u['ssh'] && !File.directory?(sshdir) }
    owner u["name"]
    group u["group"] || u['name']
    mode 0700
    action :create
  end

  # SSH秘密鍵・公開鍵生成
  key_file = "#{sshdir}/id_rsa_#{u['name']}"
  authorized_keys_file = "#{sshdir}/authorized_keys"
  execute "ssh-keygen" do
    only_if { u['ssh'] && !File.exists?(key_file) && !File.exists?(authorized_keys_file) }
    user u['name']
    group u["group"] || u['name']
    command "ssh-keygen -f #{key_file} -t rsa -b 4096 -N \"\""
    action :run
  end

  # authorized_keys作成
  pub_file = "#{key_file}.pub"
  execute "create authorized_keys" do
    only_if { u['ssh'] && File.exists?(pub_file) && !File.exists?(authorized_keys_file) }
    command "mv #{pub_file} #{authorized_keys_file} ; chmod 0600 #{authorized_keys_file}"
    user u["name"]
    group u["group"] || u['name']
    action :run
  end



end
