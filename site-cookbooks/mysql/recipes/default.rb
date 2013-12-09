#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2013, Yukihiro Ogawa
#
# All rights reserved - Do Not Redistribute
#

#必要なパッケージダウンロード
cmake = package "cmake" do
  action [:install]
  not_if "cmake -version"
end
cmake.run_action(:install)


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

cmake_opt = node['mysql']['cmake'].join(" ")

bash "install mysql" do
  user     node['mysql']['install_user']
  cwd      node['mysql']['src_dir']
  code   <<-EOH
    tar xzf #{node['mysql']['version']}.tar.gz
    cd #{node['mysql']['version']}
    cmake #{cmake_opt}
    make VERBOSE=1
    make install
    #{node['mysql']['mysql_dir']}scripts/mysql_install_db --user=#{node['mysql']['run_user']} --datadir=#{node['mysql']['mysql_dir']}data/ --basedir=#{node['mysql']['mysql_dir']}
    chown -R root.#{node['mysql']['run_user']} #{node['mysql']['mysql_dir']}
    chown -R #{node['mysql']['run_user']} #{node['mysql']['mysql_dir']}data/
  EOH
end

template "/etc/init.d/mysqld" do
  source  "mysqld.erb"
  owner    node['mysql']['install_user']
  group    node['mysql']['install_group']
  mode     00744
end

bash "start mysqld" do
  flags  '-ex'
  user   node['mysql']['install_user']
  code   <<-EOH
	/etc/init.d/mysqld start
  EOH
end
