#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2013, Yukihiro Ogawa
#
# All rights reserved - Do Not Redistribute
#

#必要なパッケージダウンロード
package "cmake28"

group "#{node['mysql']['run_group']}" do
  group_name "#{node['mysql']['run_group']}"
  action [:create]
end

#ユーザ作成
user "#{node['mysql']['run_user']}" do
  comment "#{node['mysql']['run_user']}"
  group "#{node['mysql']['run_group']}"
  username "#{node['mysql']['run_user']}"
end


remote_file "#{node['mysql']['src_dir']}/#{node['mysql']['version']}.tar.gz" do
  source "#{node['mysql']['remote_url']}"
end


bash "install mysql" do
  user     node['mysql']['install_user']
  cwd      node['mysql']['src_dir']
  code   <<-EOH
    tar xzf #{node['mysql']['version']}.tar.gz
    cd #{node['mysql']['version']}
    cmake #{cmake}
    make VERBOSE=1
    make install
    cp #{node['php']['src_dir']}#{node['php']['version']}/php.ini-production #{node['php']['conf_dir']}php.ini
  EOH
end

