##install
default['bucardo']['tmp_local'] = '/tmp/local/'
default['bucardo']['build_dir'] = '/tmp/local/bucardo_build'
default['bucardo']['user'] = 'bucardo'
default['bucardo']['bucardo_repo'] = 'git://github.com/bucardo/bucardo.git'
default['bucardo']['bin_path'] = "/usr/local/bin/bucardo"

##configure
default['bucardo']['dbname'] = 'test'
#master
default['bucardo']['master']['host'] = 'localhost'
default['bucardo']['master']['user'] = 'bucardo'
#slave
default['bucardo']['slave']['host'] = 'localhost'
default['bucardo']['slave']['user'] = 'bucardo'
default['bucardo']['slave']['ip_address'] = '0.0.0.0'

default['bucardo']['relgroup'] = 'my_rels'
default['bucardo']['dbgroup'] = 'my_group'
default['bucardo']['sync'] = 'my_sync'
