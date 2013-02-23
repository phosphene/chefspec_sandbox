prereqs = [ "perl", "curl" ]

prereqs.each do |p|
  package p
end

bash "install_cpanm" do
  code <<-EOC
curl -L http://cpanmin.us | perl - --sudo App::cpanminus
EOC
end

bash 'Test::Simple' do
  user 'root'
  group 'root'
  
end


bash 'DBIx::Safe' do
  user 'root'
  group 'root'
  
end

bash 'boolean' do
  user 'root'
  group 'root'
  
end
