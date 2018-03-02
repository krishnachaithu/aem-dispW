
# Cookbook Name:: install_dispatcher
# Recipe:: default
#
# Copyright 2018, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'install_dispatcher::preinstall'

cookbook_file "#{node[:aem][:aem_apps_dir]}/#{node[:aem][:aem_apps_tar_package]}" do
  source "#{node[:aem][:aem_apps_tar_package]}"
  owner 'root'
  group 'root'
  mode '0755'
end

execute "Untar  httpd-2.4.29" do
  cwd "#{node[:aem][:aem_apps_dir]}"
  command "tar xvf #{node[:aem][:aem_apps_tar_package]}"
end


cookbook_file "#{node[:aem][:aem_apps_dir]}/#{node[:aem][:aem_apps_apr_package]}" do
  source "#{node[:aem][:aem_apps_apr_package]}"
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file "#{node[:aem][:aem_apps_dir]}/#{node[:aem][:aem_apps_aprutil_package]}" do
  source "#{node[:aem][:aem_apps_aprutil_package]}"
  owner 'root'
  group 'root'
  mode '0755'
end

execute "Untar APACHE" do
  cwd "#{node[:aem][:aem_apps_dir]}"
  command "tar xvf #{node[:aem][:aem_apps_tar_package]}"
end

execute "Untar APR" do
  cwd "#{node[:aem][:aem_apps_dir]}"
  command "tar xvf #{node[:aem][:aem_apps_apr_package]} -C #{node[:aem][:aem_apps_dir]}/#{node[:aem][:aem_apps_package]}/srclib/"
end

execute "Untar APRUTIL" do
  cwd "#{node[:aem][:aem_apps_dir]}"
  command "tar xvf #{node[:aem][:aem_apps_aprutil_package]} -C #{node[:aem][:aem_apps_dir]}/#{node[:aem][:aem_apps_package]}/srclib/"
end

tarpkg = [ "#{node[:aem][:aem_apps_tar_package]}", "#{node[:aem][:aem_apps_aprutil_package]}", "#{node[:aem][:aem_apps_apr_package]}" ]

tarpkg.each do |pkg|
execute "remove archive" do
  cwd "#{node[:aem][:aem_apps_dir]}"
  command "rm -rf #{pkg}"
end
end

#configure apache
bash "configure apache" do
 cwd "#{node[:aem][:aem_apps_dir]}/#{node[:aem][:aem_apps_package]}"
  code <<-EOH
./configure --with-included-apr=srclib/apr --enable-mods-shared="all"  --prefix=/apps/apache-2.4
 make
 make install
 EOH
end

# copying dispatcher.so file to apache modules after extracting 

cookbook_file "#{node[:aem][:aem_apps_module]}/#{node[:aem][:aem_apps_dispatcher_file]}" do
    source "#{node[:aem][:aem_apps_dispatcher_file]}"
    owner 'root'
    group 'root'
    mode '0755'
end


# copying templates

template "#{node[:aem][:aem_apps_httpd_conf_path]}/dispatcher.any" do
   source "dispatcher.erb"
   owner 'root'
   mode 0600
end

template "#{node[:aem][:aem_apps_httpd_conf_path]}/httpd.conf" do
     source 'httpd.erb'
     owner 'root'
     mode 0600
end

# Restarting apache service after conf change
template "/usr/lib/systemd/system/httpd.service" do
  source "aem_apache_init_script.erb"
  owner 'root'
  mode 0644
end

link "/apps/apache-2.4/modules/mod_dispatcher.so" do
  to "/apps/apache-2.4/modules/dispatcher-apache2.4-4.2.3.so"
end


service "httpd" do
 supports :status => true, :restart => true, :reload => true
  action [:enable, :restart]
end

