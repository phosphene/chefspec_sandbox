

node.set['bucardo']['master']['host'] = 'sequel2-dub-stage.colortechnology.com'
node.set['bucardo']['dbname'] = 'sequel'
node.set['bucardo']['excluded_tables_array'] = ['public.sessions', 'public.schema_info','public.accts_countries', 'public.accts_users']

 
log "#{cookbook_name}::#{recipe_name} tests slave_setup."




include_recipe 'bucardo::setup_slave'
