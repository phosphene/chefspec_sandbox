bucardo_secret = Chef::EncryptedDataBagItem.load_secret("#{node['bucardo']['secretpath']}")
bucardo_creds = Chef::EncryptedDataBagItem.load("passwords", "bucardo", bucardo_secret)
bucardo_master_pw = bucardo_creds["#{node['bucardo']['master']['user']}"]
bucardo_slave_pw = bucardo_creds["#{node['bucardo']['slave']['user']}"]


ruby_block "modify pg_conf for bucardo user" do
  block do
    require 'chef/util/file_edit'
    nc = Chef::Util::FileEdit.new("/etc/postgresql/8.4/main/pg_hba.conf")
    nc.insert_line_after_match(/local.*?postgres.*ident/, "hostssl   all    #{node['bucardo']['slave']['user']}   #{node['bucardo']['slave']['ip_address']}  #{node['bucardo']['slave']['subnet_mask']}    md5")
    nc.write_file
    Chef::Log.info "Inserted #{node['bucardo']['slave']['user']} md5 for #{node['bucardo']['slave']['ip_address']}"
    not_if %Q{psql -c '\\du'|grep #{node['bucardo']['slave']['user']}}, :user => 'postgres'
  end
end



ruby_block "modify postgresql.conf to listen on all ip addresses" do
  block do
    require 'chef/util/file_edit'
    nc = Chef::Util::FileEdit.new("/etc/postgresql/8.4/main/postgresql.conf")
    nc.search_file_replace_line(/.+?listen_addresses.*?=.*?localhost.*/, "listen_addresses = '*'")
    nc.write_file
    Chef::Log.info "modified postgresql.conf to listen on all ip addresses"
      not_if %Q{ psql -c '\\du'|grep #{node['bucardo']['slave']['user']} }, :user => 'postgres'
  end
end

service 'postgresql-8.4' do
  action :restart
      not_if %{psql -c '\\du'|grep #{node['bucardo']['slave']['user']}}, :user => 'postgres'
end


execute "create bucardo user in postgres" do
  user 'postgres'
  command %{psql -c "create #{node['bucardo']['slave']['user']} WITH SUPERUSER PASSWORD '#{bucardo_master_pw}'"}
  action :run
  not_if %{psql -c '\\du'| grep #{node['bucardo']['slave']['user']}}, :user => 'postgres'
end
