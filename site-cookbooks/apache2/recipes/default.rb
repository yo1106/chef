#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2013, Kazuya Sato
#
# All rights reserved - Do Not Redistribute
#

#Apacheインストールに必要なAPRのインストール
remote_file "#{node['apache']['src_dir']}#{node['apache']['apr_version']}.tar.gz" do
  source "#{node['apache']['remote_apr_url']}#{node['apache']['apr_version']}.tar.gz"
end

bash "install apr" do
  action :nothing
  not_if "ls /usr/local/apr/"
  user node['apache']['install_user']
  cwd  node['apache']['src_dir']
  code <<-EOH
	tar xzf #{node['apache']['apr_version']}.tar.gz
	cd #{node['apache']['apr_version']}
	./configure
	make
	make install
  EOH
end


remote_file "#{node['apache']['src_dir']}#{node['apache']['apr-util_version']}.tar.gz" do
  source "#{node['apache']['remote_apr_url']}#{node['apache']['apr-util_version']}.tar.gz"
end

bash "install apr util" do
  not_if "ls /usr/local/apr/lib/apr-util-1/"
  user node['apache']['install_user']
  cwd  node['apache']['src_dir']
  code <<-EOH
        tar xzf #{node['apache']['apr-util_version']}.tar.gz
        cd #{node['apache']['apr-util_version']}
        ./configure --with-apr=/usr/local/apr
        make
        make install
  EOH
end


# PCREのインストール
remote_file "#{node['apache']['src_dir']}#{node['apache']['pcre_version']}.tar.gz" do
  source "#{node['apache']['pcre_remote_url']}#{node['apache']['pcre_version']}.tar.gz/"
end

bash "install pcre" do
  not_if "ls /usr/local/lib/libpcre.so"
  user node['apache']['install_user']
  cwd  node['apache']['src_dir']
  code <<-EOH
        tar xzf #{node['apache']['pcre_version']}.tar.gz
        cd #{node['apache']['pcre_version']}
        ./configure
        make
        make install
  EOH
end




#ソースコードダウンロード
remote_file "#{node['apache']['src_dir']}/#{node['apache']['version']}.tar.gz" do
  source "#{node['apache']['remote_base_url']}#{node['apache']['version']}.tar.gz"
end

#展開してインストール
bash "install apache" do
  user     node['apache']['install_user']
  cwd      node['apache']['src_dir']
  code   <<-EOH
    rm -rf #{node['apache']['version']}
    tar xzf #{node['apache']['version']}.tar.gz
    cd #{node['apache']['version']}
    ./configure #{node['apache']['configure']}
    make
    make install
  EOH
end

include_recipe 'apache2::make_conf'
#template "#{node['apache']['dir']}conf/httpd.conf" do
#  source   "httpd.conf.erb"
#  owner    node['apache']['install_user']
#  group    node['apache']['install_group']
#  mode     00644
#  notifies :run, 'bash[restart apache]', :immediately
#end

for include_file in node['apache']['include_files']
  template "#{node['apache']['dir']}conf/extra/#{include_file}.conf" do
    source   "#{include_file}.conf.erb"
    owner    node['apache']['install_user']
    group    node['apache']['install_group']
    mode     00644
  end
end

template "/etc/init.d/httpd" do
  source  "httpd.erb"
  owner    node['apache']['install_user']
  group    node['apache']['install_group']
  mode     00744
end



bash "start apache" do
  action :nothing
  flags  '-ex'
  user   node['apache']['install_user']
  code   <<-EOH
    /etc/init.d/httpd start
  EOH
end

bash "restart apache" do
  action :nothing
  flags  '-ex'
  user   node['apache']['install_user']
  code   <<-EOH
    /etc/init.d/httpd restart
  EOH
end
