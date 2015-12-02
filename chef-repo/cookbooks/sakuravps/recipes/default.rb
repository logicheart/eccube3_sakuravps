#
# Cookbook Name:: sakuravps
# Recipe:: default
#
# Copyright 2015, hiroyasu55(LogicHeart)
#
# All rights reserved
#

# SELinux無効化
include_recipe "selinux::disabled"

# iptables
include_recipe "iptables"
iptables_rule 'iptables' do
  action :enable
end

# ClamAVインストール
include_recipe "clamav"

# パッケージ最新化
execute "yum update" do
  command 'yum -y update --exclude=kernel*'
  action :run
end

# ユーザー作成
include_recipe "sakuravps::users"
