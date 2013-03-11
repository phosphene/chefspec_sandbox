include_recipe "bucardo::util_recipe"

bucardo_secret = Chef::EncryptedDataBagItem.load_secret("#{node['bucardo']['secretpath']}")
bucardo_creds = Chef::EncryptedDataBagItem.load("passwords", "bucardo", bucardo_secret)

#namespace to local
dbname = node.bucardo.dbname
master = node.bucardo.master
slave = node.bucardo.slave
master['pass'] = bucardo_creds["#{master['user']}"]
slave['pass'] = bucardo_creds["#{slave['user']}"]
#rels_name = node.bucardo.rels_name
#db_group_name = node.bucardo.db_group_name
#sync_name = node.bucardo.sync_name



test_this_method()

db_dump = get_remote_db_backup(aws_config)

remote_file "#{Chef::Config[:file_cache_path]}/#{db_dump.key}" do
  source "#{db_dump.url}"
  action :create_if_missing
end



execute "alter_bucardo_password" do
  user 'postgres'
  command %|psql -c "ALTER USER bucardo WITH PASSWORD '#{slave['pass']}'"|
  action :run
end

execute 'create local slave db' do
  user 'postgres'
  command %| createdb #{dbname} |
  action :run
  not_if "psql --list|grep #{dbname}", :user => 'postgres'
end





execute  'add master db to bucardo' do
  user 'bucardo'
  command %| bucardo add db #{dbname}_master dbname=#{dbname} host=#{master['host']} dbuser=#{master['user']}  pass=#{master['pass']} |
  action :run
end


execute  'add slave db to bucardo' do
  user 'bucardo'
  command %|bucardo add db #{dbname}_slave dbname=#{dbname} host=#{slave['host']} dbuser=#{slave['user']} pass=#{slave['pass']} |
  action :run
end

execute  'add tables to bucardo relgroup' do
  user 'bucardo'
  command %{bucardo add table all relgroup=#{rels_name} db=#{dbname}_master}
  action :run
end

excluded_tables_array.each do |val|

  execute "remove excluded #{val} table with no primary key" do
   user 'bucardo'
   command %|bucardo remove table #{val} |
   action :run
  end

end



execute  'add sequences to bucardo relgroup' do
  user 'bucardo'
  command %{bucardo add sequence all relgroup=#{rels_name} db=#{dbname}_master}
  action :run
end

 execute  'create db group' do
   user 'bucardo'
   command %|bucardo add dbgroup #{db_group_name} #{dbname}_slave:target #{dbname}_master:source|
   action :run
 end


execute  'create sync' do
  user 'bucardo'
  command %| bucardo add sync #{sync_name} relgroup=#{rels_name} dbs=#{db_group_name}|
  action :run
end

execute  'activate sync' do
  user 'bucardo'
  command %| bucardo activate sync #{sync_name}|
  action :run
end


directory '/var/run/bucardo' do
  user 'bucardo'
  group 'bucardo'
  action :create
end


directory '/var/log/bucardo' do
  user 'bucardo'
  group 'bucardo'
  action :create
end



execute  'start bucardo' do
  cwd '/tmp'
  user 'bucardo'
  command 'bucardo start'
  action :run
end
