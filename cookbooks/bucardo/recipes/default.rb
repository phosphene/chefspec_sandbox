include_recipe "bucardo::packages"
include_recipe "bucardo::included_recipe"

package 'git-core' do
  action :install
end

directory "/tmp/local/" do
  action :create
end




git "checkout-bucardo" do
  repository "git://github.com/phosphene/bucardo.git"
  reference "master"
  destination "/tmp/local/bucardo_build"
end

extract_path = "/tmp/local/bucardo_build"
#if { ::File.exists?(extract_path) }

bash 'build_bucardo' do
  cwd extract_path
  user 'root'
  group 'root'

  code <<-EOH
    perl Makefile.PL
    make
    make install
    EOH
  action :run
end

user 'bucardo' do
 action :create
end

ruby_block "modify pg_conf for bucardo install" do
  block do
    require 'chef/util/file_edit'
    nc = Chef::Util::FileEdit.new("/etc/postgresql/8.4/main/pg_hba.conf")
    nc.insert_line_after_match(/local.*?postgres.*ident/, "local   all      bucardo        trust")
    nc.write_file
    Chef::Log.info "Inserted bucardo trust"
  end
end


service 'postgresql-8.4' do
  action :restart
end





bash 'install_bucardo' do
  user 'postgres'

  code <<-EOH
    bucardo install --batch
    EOH
  action :run
end
