#extract_path = "/tmp/local/bucardo_build"
#if { ::File.exists?(extract_path) }

dbname = 'sequel'
db_name = 'sequel'




dbname = 'sequel'
db_name = 'sequel'
master = {'host' => 'test',
  'user' => 'bucardo',
  'pass' => 'none'
}

slave = {'host' => 'localhost',
  'user' => 'bucardo',
  'pass' => 'none'
}

excluded_tables_array = %w(public.sessions public.accts_countries public.schema_info public.accts_users)
rels_name = 'my_rels'
db_group_name = 'my_group'
sync_name = 'my_sync'

execute "alter_bucardo_password" do
  user 'postgres'
  command %|psql -c "ALTER USER bucardo WITH PASSWORD '#{slave['pass']}'"|
  action :run
end

execute 'create local slave db' do
  user 'postgres'
  command %| createdb #{db_name} |
  action :run
  not_if "psql --list|grep #{db_name}", :user => 'postgres'
end



file '/var/lib/postgresql/.pgpass' do
  owner 'postgres'
  mode 0600
  action :create
end

execute 'append to pgpass file' do
  user 'postgres'
  command %| echo "#{master['host']}:*:#{db_name}:#{master['user']}:#{master['pass']}" >> /var/lib/postgresql/.pgpass |
  action :run

end




execute "dump master schema and load to local slave" do
  cwd '/var/lib/postgresql'
  user 'postgres'
  command %$ pg_dump -h #{master['host']} -U bucardo --schema-only #{dbname} | psql  -d #{dbname} $
  action :run
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
