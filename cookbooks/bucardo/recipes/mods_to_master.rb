bucardo_creds = Chef::EncryptedDataBagItem.load("passwords", "bucardo")
bucardo_pw = bucardo_creds["#{node['bucardo']['user']}"]





ruby_block "modify pg_conf for bucardo user" do
  block do
    require 'chef/util/file_edit'
    nc = Chef::Util::FileEdit.new("/etc/postgresql/8.4/main/pg_hba.conf")
    nc.insert_line_after_match(/local.*?postgres.*ident/, "hostssl    #{node['bucardo']['master']['dbname']}    #{node['bucardo']['user']}   #{node['bucardo']['slave']['ip_address']}     md5")
    nc.write_file
    Chef::Log.info "Inserted #{node['bucardo']['user']} md5 for #{node['bucardo']['slave']['ip_address']}"
    not_if "psql -c '\du'|grep #{node['bucardo']['user']}", :user => 'postgres'
  end
end


service 'postgresql-8.4' do
  action :restart
  not_if "psql -c '\du'|grep #{node['bucardo']['user']}", :user => 'postgres'
end


execute "create bucardo user in postgres" do
  user 'postgres'
  command %{psql -c "Create USER #{node['bucardo']['user']} WITH PASSWORD '#{bucardo_pw}'"}
  action :run
  not_if "psql -c '\du'|grep #{node['bucardo']['user']}", :user => 'postgres'
end
