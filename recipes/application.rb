include_recipe 'build-essential::default'
include_recipe 'python::pip'
include_recipe 'python::virtualenv'

package 'git'
package 'postgresql-devel'
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
    supports :manage_home => true
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

python_pip "git+https://github.com/SukachVitally/kiki.git" do
  action :install
  virtualenv "#{node[:home_dir]}venvs/test"
end

template "#{node[:home_dir]}uwsgi.ini" do
    source 'uwsgi.ini.erb'
    mode '0755'
    variables(
        :home_dir => node[:home_dir]
    )
end

pyinter = "#{node[:home_dir]}venvs/test/bin/python"

execute 'db migrate' do
 command "#{pyinter} #{node[:home_dir]}kiki/manage.py migrate"
end


package 'epel-release'
package 'nodejs'
package 'npm'

execute 'install bower' do
 command "npm install bower -g"
end

directory "#{node[:home_dir]}kiki/vendor" do
    owner 'test'
    group 'test-users'
    mode '0777'
    action :create
end

execute 'bower django install' do
 command "#{pyinter} #{node[:home_dir]}kiki/manage.py bower_install"
 user 'test'
end

execute 'start uwsgi' do
 command "uwsgi #{node[:home_dir]}uwsgi.ini"
end




