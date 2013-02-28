#extract_path = "/tmp/local/bucardo_build"
#if { ::File.exists?(extract_path) }


bash 'create test dbs' do
  user 'postgres'
  
  code <<-EOH
    createdb test_master
    createdb test_slave
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
master.host = 'localhost'
slave.host = 'localhost'
master.user = 'bucardo'
master.pass = ''
slave.user = 'bucardo'
slave.pass = ''


bash  'add dbs to bucardo' do
  user 'bucardo'
  code <<-EOH
  bucardo add db master_#{dbname} dbname=#{dbname} host=#{master.host} user=#{master.user} pass=#{master.pass}
  bucardo add db slave_#{dbname} dbname=#{dbname} host=#{slave.host} user=#{slave.user} pass=#{slave.pass}
  EOH
  action :run
end

bash  'add tables to bucardo' do
  user 'bucardo'
  code <<-EOH
  bucardo add table #{table_name} relgroup=myrels db=slave_#{db_name} 
  EOH
  action :run
end



bash  'create db group' do
  user 'bucardo'
  code <<-EOH
  bucardo add dbgroup #{db_group_name} relgroup=#{rels_name} db=slave_#{db_name} 
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

