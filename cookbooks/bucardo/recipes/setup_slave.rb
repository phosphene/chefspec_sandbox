bucardo_secret = Chef::EncryptedDataBagItem.load_secret("#{node['bucardo']['secretpath']}")
bucardo_creds = Chef::EncryptedDataBagItem.load("passwords", "bucardo", bucardo_secret)

#namespace to local
dbname = node.bucardo.dbname
master = node.bucardo.master
slave = node.bucardo.slave
master_pass = bucardo_creds["#{master['user']}"]
slave_pass = bucardo_creds["#{slave['user']}"]
rels_name = node.bucardo.relgroup
db_group_name = node.bucardo.dbgroup
sync_name = node.bucardo.sync_name
excluded_tables_array = node.bucardo.excluded_tables_array



execute "alter_bucardo_password" do
  user 'postgres'
  command %|psql -c "ALTER USER bucardo WITH PASSWORD '#{slave_pass}'"|
  action :run
end

execute 'create local slave db' do
  user 'postgres'
  command %| createdb #{dbname} |
  action :run
  not_if "psql --list|grep #{dbname}", :user => 'postgres'
end


execute 'append to pgpass file' do
  user 'postgres'
  command %| echo "#{node.bucardo.master['host']}:*:#{node.bucardo.dbname}:#{node.bucardo.master['user']}:#{master_pass}" >> /var/lib/postgresql/.pgpass |
  action :run
  not_if { File.exists? '/var/lib/postgresql/.pgpass' } 
end



file '/var/lib/postgresql/.pgpass' do
  owner 'postgres'
  mode "600"
  
end


bash "dump master schema and load to local slave" do
  cwd '/var/lib/postgresql'
  user 'postgres'
  code <<-EOH
    set -o pipefail
    pg_dump -h #{node.bucardo.master['host']} -U bucardo --schema-only #{dbname} | psql  -d #{dbname}
    EOH
  action :run
  environment 'PGSSLMODE' => 'require'
end



execute  'add master db to bucardo' do
  user 'bucardo'
  command %| bucardo add db #{dbname}_master dbname=#{dbname} host=#{master['host']} dbuser=#{master['user']}  pass=#{master_pass} |
    action :run
end


execute  'add slave db to bucardo' do
  user 'bucardo'
  command %|bucardo add db #{dbname}_slave dbname=#{dbname} host=#{slave['host']} dbuser=#{slave['user']} pass=#{slave_pass} |
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
  command %|bucardo add sequence all relgroup=#{rels_name} db=#{dbname}_master |
  action :run
end

execute  'create db group' do
  user 'bucardo'
  command %|bucardo add dbgroup #{db_group_name} #{dbname}_slave:target #{dbname}_master:source|
    action :run
end


execute  'create sync' do
  user 'bucardo'
  command %| bucardo add sync #{sync_name} relgroup=#{rels_name} dbs=#{db_group_name} autokick=0|
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


# bash 'dump data from master to slave' do
#   cwd '/var/lib/postgresql'
#   user 'postgres'
#   code <<-EOH
#    set -o pipefail
#    pg_dump -U #{master['user']} -h #{master['host']} --data-only -N bucardo #{dbname} | \
#    psql -U #{slave['user']} -h #{slave['host']} -d #{dbname} }
#    EOH
#   action :run
#   environment 'PGSSLMODE' => 'require'
# end


execute 'update sync' do
  user 'bucardo'
  command %| bucardo update sync #{sync_name} autokick=1|
  action :run
end


execute  'activate sync' do
  user 'bucardo'
  command %| bucardo activate sync #{sync_name}|
  action :run
end





execute 'bucardo reload config' do
  user 'bucardo'
  command %| bucardo reload config|
  action :run
end
