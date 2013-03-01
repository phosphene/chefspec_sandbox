#extract_path = "/tmp/local/bucardo_build"
#if { ::File.exists?(extract_path) }

dbname = 'test'
db_name = 'test'


bash 'create test dbs' do
  user 'postgres'

  code <<-EOH
    dropdb #{db_name}_master
    dropdb #{db_name}_slave
    createdb #{db_name}_master
    createdb #{db_name}_slave
    EOH
  action :run
end


bash 'add test data to test dbs' do
  user 'postgres'

  code <<-EOH
     /usr/lib/postgresql/8.4/bin/pgbench -i test_master
     /usr/lib/postgresql/8.4/bin/pgbench -i test_slave
    EOH
  action :run
end

dbname = 'test'
db_name = 'test'
master = {'host' => 'localhost',
  'user' => 'bucardo',
  'pass' => 'password'
}

slave = {'host' => 'localhost',
  'user' => 'bucardo',
  'pass' => 'password'
}

table_name = 'pgbench_tellers'
rels_name = 'my_rels'
db_group_name = 'my_group'
sync_name = 'my_sync'

bash 'alter bucardo password' do
  user 'postgres'
  code <<-EOH
  psql -c "ALTER USER bucardo WITH PASSWORD '<#{master['pass']}>';"
  EOH
  action :run
end


bash  'add dbs to bucardo' do
  user 'bucardo'
  code <<-EOH
  bucardo add db #{dbname}_master dbname=#{dbname}_master dbuser=#{master['user']} pass=#{master['pass']}
  bucardo add db #{dbname}_slave dbname=#{dbname}_slave dbuser=#{slave['user']} pass=#{slave['pass']}
  EOH
  action :run
  not_if 'bucardo list db | grep Database: #{dbname}_master'
end

bash  'add tables to bucardo' do
  user 'bucardo'
  code <<-EOH
  bucardo add table #{table_name} relgroup=#{rels_name} db=#{dbname}_slave
  EOH
  action :run
end



 bash  'create db group' do
   user 'bucardo'
   code <<-EOH
    bucardo add dbgroup #{db_group_name} test_slave:target test_master:source
   EOH
   action :run
 end


bash  'create sync' do
  user 'bucardo'
  code <<-EOH
  bucardo add sync #{sync_name} relgroup=#{rels_name} dbs=#{db_group_name} autokick=0
  EOH
  action :run
end

directory "/var/run/bucardo" do
  user 'bucardo'
  group 'bucardo'
  action :create
end


directory "/var/log/bucardo" do
  user 'bucardo'
  group 'bucardo'
  action :create
end



bash  'start bucardo' do
  cwd '/tmp'
  user 'bucardo'

  code <<-EOH
  bucardo start
  EOH
  action :run
end
