##install
default['bucardo']['tmp_local'] = '/tmp/local/'
default['bucardo']['build_dir'] = '/tmp/local/bucardo_build'
default['bucardo']['user'] = 'bucardo'
default['bucardo']['bucardo_repo'] = 'git://github.com/bucardo/bucardo.git'
default['bucardo']['bin_path'] = "/usr/local/bin/bucardo"

##configure
#general
default['bucardo']['dbname'] = 'test'
default['bucardo']['secretpath'] = '/etc/chef/data_bag_key'
#master
default['bucardo']['master']['host'] = 'some.remote.com'


default['bucardo']['master']['user'] = 'bucardo'
#slave
default['bucardo']['slave']['host'] = 'localhost'
default['bucardo']['slave']['user'] = 'bucardo'
default['bucardo']['slave']['ip_address'] = '0.0.0.0'
default['bucardo']['slave']['subnet_mask'] = '255.255.255.0'
default['bucardo']['slave']['superuser'] = 'postgres'

default['bucardo']['pushdelta_relgroup'] = 'my_pushdelta_rels'
default['bucardo']['fullcopy_relgroup'] = 'my_fullcopy_rels'


default['bucardo']['pushdelta_dbgroup'] = 'my_pushdelta_dbgroup'
default['bucardo']['fullcopy_dbgroup'] = 'my_fullcopy_dbgroup'



default['bucardo']['fullcopy_sync'] = 'my_fullcopy_sync'
default['bucardo']['pushdelta_sync'] = 'my_pushdelta_sync'
default['bucardo']['excluded_delta_tables_array'] = []
default['bucardo']['include_fullcopy_tables_array'] = []
