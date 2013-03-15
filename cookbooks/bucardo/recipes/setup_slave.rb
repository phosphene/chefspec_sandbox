#get my secrets
bucardo_secret = Chef::EncryptedDataBagItem.load_secret("#{node['bucardo']['secretpath']}")
bucardo_creds = Chef::EncryptedDataBagItem.load("passwords", "bucardo", bucardo_secret)


#namespace to local

#dbname and master and slave dbs
dbname = node.bucardo.dbname
master = node.bucardo.master
slave = node.bucardo.slave
master_pass = bucardo_creds["#{master['user']}"]
slave_pass = bucardo_creds["#{slave['user']}"]

#bucardo groups and syncs
pushdelta_relgroup = node.bucardo.pushdelta_relgroup
fullcopy_relgroup = node.bucardo.fullcopy_relgroup
fullcopy_dbgroup = node.bucardo.fullcopy_dbgroup
fullcopy_sync = node.bucardo.fullcopy_sync
pushdelta_sync = node.bucardo.pushdelta_sync

#exclude and include tables
excluded_delta_tables_array = node.bucardo.excluded_delta_tables_array
include_fullcopy_tables_array = node.bucardo.include_fullcopy_tables_array

#namespace to local for shorter, more succint lines
dbname = node.bucardo.dbname
master = node.bucardo.master
slave = node.bucardo.slave
master_pass = bucardo_creds["#{master['user']}"]
slave_pass = bucardo_creds["#{slave['user']}"]

pushdelta_relgroup = node.bucardo.pushdelta_relgroup
fullcopy_relgroup = node.bucardo.fullcopy_relgroup

db_group_name = node.bucardo.dbgroup


fullcopy_sync = node.bucardo.fullcopy_sync_name
pushdelta_sync = node.bucardo.pushdelta_sync_name
excluded_delta_tables_array = node.bucardo.excluded_delta_tables_array
include_fullcopy_tables_array = node.bucardo.include_fullcopy_tables_array

#begin recipe

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




execute  'add tables to bucardo pushdelta relgroup' do
  user 'bucardo'
  command %{bucardo add table all relgroup=#{pushdelta_relgroup} db=#{dbname}_master}
  action :run
end

excluded_delta_tables_array.each do |val|

  execute "remove excluded #{val} table with no primary key" do
    user 'bucardo'
    command %|bucardo remove table #{val} |
    action :run
  end

end



execute  'add sequences to bucardo pushdelta relgroup' do
  user 'bucardo'
  command %|bucardo add sequence all relgroup=#{pushdelta_relgroup} db=#{dbname}_master |
  action :run
end

execute  'create pushdelta dbgroup' do
  user 'bucardo'
  command %|bucardo add dbgroup #{pushdelta_dbgroup} #{dbname}_slave:target #{dbname}_master:source|
    action :run
end


execute  'create pushdelta sync' do
  user 'bucardo'
  command %| bucardo add sync #{pushdelta_sync} relgroup=#{pushdelta_relgroup} dbs=#{pushdelta_dbgroup} onetimecopy=2|
    action :run
end


execute  'create dbgroup for full_copy' do
  user 'bucardo'
  command %|bucardo add dbgroup #{fullcopy_dbgroup} #{dbname}_master:source  #{dbname}_slave:fullcopy|
  action :run
end

execute  'create relgroup for full_copy' do
  user 'bucardo'
  command %|bucardo add relgroup #{fullcopy_relgroup} db=#{dbname}_master |
  action :run
end

include_fullcopy_tables_array.each do |val|
  execute "add full_copy of #{val} table with no primary key" do
    user 'bucardo'
    command %|bucardo add table #{val} relgroup=#{fullcopy_relgroup} db=#{dbname}_master|
    action :run
  end
end


execute  'create fullcopy sync' do
  user 'bucardo'
  command %| bucardo add sync #{fullcopy_sync} relgroup=#{fullcopy_relgroup} dbs=#{fullcopy_dbgroup} onetimecopy=2|
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
  cwd '/var/run/bucardo'
  user 'bucardo'
  command 'bucardo start'
  action :run
end








# execute  'add tables to bucardo relgroup' do
#   user 'bucardo'
#   command %{bucardo add table all relgroup=#{rels_pushdelta_name} db=#{dbname}_master}
#   action :run
# end

# excluded_tables_array.each do |val|

#   execute "remove excluded #{val} table with no primary key" do
#     user 'bucardo'
#     command %|bucardo remove table #{val} |
#     action :run
#   end

# end



# execute  'add sequences to bucardo relgroup' do
#   user 'bucardo'
#   command %|bucardo add sequence all relgroup=#{rels_pushdelta_name} db=#{dbname}_master |
#   action :run
# end

# execute  'create db group' do
#   user 'bucardo'
#   command %|bucardo add dbgroup #{db_group_name} #{dbname}_slave:target #{dbname}_master:source|
#     action :run
# end


# execute  'create pushdelta sync' do
#   user 'bucardo'
#   command %| bucardo add sync #{sync_pushdelta_name} relgroup=#{rels_pushdelta_name} dbs=#{db_group_name} onetimecopy=2|
#     action :run
# end


# execute  'activate sync' do
#   user 'bucardo'
#   command %| bucardo activate sync #{sync_pushdelta_name}|
#   action :run
# end


# execute  'create relgroup for full_copy' do
#   user 'bucardo'
#   command %|bucardo add relgroup #{relgroup_fullcopy_name} |
#   action :run
# end



# full_copy_tables_array.each do |val|

#   execute "add full_copy of #{val} table with no primary key" do
#     user 'bucardo'
#     command %|bucardo add table #{val} |
#     action :run
#   end

# end


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
  cwd '/var/run/bucardo'
  user 'bucardo'
  command 'bucardo start'
  action :run
end


# # bash 'dump data from master to slave' do
# #   cwd '/var/lib/postgresql'
# #   user 'postgres'
# #   code <<-EOH
# #    set -o pipefail
# #    pg_dump -U #{master['user']} -h #{master['host']} --data-only -N bucardo #{dbname} | \
# #    psql -d #{dbname}
# #    EOH
# #   action :run
# #   environment 'PGSSLMODE' => 'require'
# # end




# execute 'bucardo reload sync' do
#   user 'bucardo'
#   command %| bucardo status sync #{sync_name}|
#   action :run
# end
