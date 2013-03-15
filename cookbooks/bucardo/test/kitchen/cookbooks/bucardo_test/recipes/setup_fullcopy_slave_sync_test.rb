node.set['bucardo']['master']['host'] = 'sequel2-dub-stage.colortechnology.com'
node.set['bucardo']['dbname'] = 'sequel'
node.set['bucardo']['excluded_delta_tables_array'] = ['public.sessions', 'public.schema_info','public.accts_countries', 'public.accts_users']
node.set['bucardo']['include_fullcopy_tables_array'] = ['public.schema_info','public.accts_countries', 'public.accts_users']

log "#{cookbook_name}::#{recipe_name} tests slave_setup."



bucardo_secret = Chef::EncryptedDataBagItem.load_secret("#{node['bucardo']['secretpath']}")
bucardo_creds = Chef::EncryptedDataBagItem.load("passwords", "bucardo", bucardo_secret)

#namespace to local
dbname = node.bucardo.dbname
master = node.bucardo.master
slave = node.bucardo.slave
master_pass = bucardo_creds["#{master['user']}"]
slave_pass = bucardo_creds["#{slave['user']}"]
pushdelta_relgroup = node.bucardo.pushdelta_relgroup
fullcopy_relgroup = node.bucardo.fullcopy_relgroup



fullcopy_dbgroup = node.bucardo.fullcopy_dbgroup
fullcopy_sync = node.bucardo.fullcopy_sync
pushdelta_sync = node.bucardo.pushdelta_sync
excluded_delta_tables_array = node.bucardo.excluded_delta_tables_array
include_fullcopy_tables_array = node.bucardo.include_fullcopy_tables_array






# execute  'create relgroup for full_copy' do
#   user 'bucardo'
#   command %|bucardo add relgroup #{fullcopy_relgroup} db=#{dbname}_master |
#   action :run
# end



# include_fullcopy_tables_array.each do |val|

#   execute "add full_copy of #{val} table with no primary key" do
#     user 'bucardo'
#     command %|bucardo add table #{val} relgroup=#{fullcopy_relgroup} db=#{dbname}_master|
#     action :run
#   end

# end


# execute  'create fullcopy sync' do
#   user 'bucardo'
#   command %| bucardo add sync #{fullcopy_sync} relgroup=#{fullcopy_relgroup} dbs=#{fullcopy_db_group} onetimecopy=1|
#   action :run
# end


execute  'create fullcopy sync' do
  user 'bucardo'
  command %| bucardo add sync #{fullcopy_sync} relgroup=#{fullcopy_relgroup} dbs=#{fullcopy_dbgroup} onetimecopy=1|
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

execute  'activate sync' do
  user 'bucardo'
  command %| bucardo activate sync #{pushdelta_sync}|
  action :run
end



execute  'kick fullcopy sync' do
  user 'bucardo'
  command %| bucardo kick sync #{pushdelta_sync}|
  action :run
end


execute  'activate sync' do
  user 'bucardo'
  command %| bucardo activate sync #{fullcopy_sync}|
  action :run
end


execute  'kick fullcopy sync' do
  user 'bucardo'
  command %| bucardo kick sync #{fullcopy_sync}|
  action :run
end
