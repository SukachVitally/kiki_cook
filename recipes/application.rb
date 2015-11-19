include_recipe 'build-essential::default'
include_recipe 'python::pip'
include_recipe 'python::virtualenv'

package 'python-devel'
package 'openssl-devel'
package 'httpd-tools'
package 'pcre'
package 'pcre-devel'
python_pip 'uwsgi'

group 'test-users' do
  action :create
  append true
end

user 'test' do
    group 'test-users'
    system true
    shell '/bin/bash'
    home '/home/test'
    supports  :manage_home => true
end
Chef::Log.warn("Test user created!!!!!!")

Chef::Log.warn("#{node[:home_dir]}venvs")

directory "#{node[:home_dir]}venvs" do
    owner 'test'
    group 'test-users'
    mode '0777'
    action :create
end

execute 'venv init' do
  command "virtualenv #{node[:home_dir]}venvs/test"
  action :run
end


git "#{node[:home_dir]}kiki" do
  repository 'https://github.com/SukachVitally/kiki.git'
  action :sync
end



