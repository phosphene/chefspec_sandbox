prereqs = [ "perl", "curl" ]

prereqs.each do |p|
  package p
end

bash "install_cpanm" do
  user 'root'
  group 'root'

  code <<-EOC
curl -L http://cpanmin.us | perl - --sudo App::cpanminus
EOC
  action :run
end

bash 'install_Test::Simple' do
  user 'root'
  group 'root'
  code <<-EOC
cpanm Test::Simple
EOC
  action :run  
end


bash 'install_DBIx::Safe' do
  user 'root'
  group 'root'
  code <<-EOC
cpanm DBIx::Safe
EOC
  action :run  
end


bash 'install_boolean' do
  user 'root'
  group 'root'
  code <<-EOC
cpanm boolean
EOC
  action :run  
end

