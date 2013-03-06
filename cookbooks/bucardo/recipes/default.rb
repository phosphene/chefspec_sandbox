include_recipe "bucardo::packages"
include_recipe "bucardo::included_recipe"

package 'git-core' do
  action :install
end

user "#{node['bucardo']['user']}" do
  action :create
  shell '/bin/bash'
  home "/home/#{node['bucardo']['user']}"
  supports :manage_home => true
end

directory "#{node['bucardo']['tmp_local']}" do
  user node['bucardo']['user']
  action :create
end


git "checkout-bucardo" do
  user 'root'
  repository  node['bucardo']['bucardo_repo']
  reference "master"
  destination node['bucardo']['build_dir']
end

bash 'build_bucardo' do
  cwd node['bucardo']['build_dir']
  user 'root'
  group 'root'

  code <<-EOH
    perl Makefile.PL
    make
    make install
    EOH
  action :run
  not_if "File.exists?(node.['bucardo']['bucardo_bin_path'])"
end


ruby_block "modify pg_conf for bucardo install" do
  block do
    require 'chef/util/file_edit'
    nc = Chef::Util::FileEdit.new("/etc/postgresql/8.4/main/pg_hba.conf")
    nc.insert_line_after_match(/local.*?postgres.*ident/, "local   all      #{node['bucardo']['slave']['user']}        trust")
    nc.write_file
    Chef::Log.info "Inserted #{node['bucardo']['user']} trust"
    not_if "psql -c '\du'|grep #{node['bucardo']['user']}", :user => 'postgres'
  end
end


service 'postgresql-8.4' do
  action :restart
  not_if "psql -c '\du'|grep #{node['bucardo']['user']}", :user => 'postgres'
end


bash 'install_bucardo' do
  user 'postgres'

  code <<-EOH
    bucardo install --batch
    EOH
  action :run
  not_if "psql --list|grep #{node['bucardo']['user']}", :user => 'postgres'

end
