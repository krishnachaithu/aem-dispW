%w(gcc libtool make pcre-devel openssl expat-devel).each do |pkg|
  package pkg do
   action :install
end
end


# Installing apache package 
directory "#{node[:aem][:aem_apps_dir]}/apache-2.4" do
  recursive true
  action :create
end

