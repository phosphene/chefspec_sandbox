#
# Cookbook Name:: bucardo
# Recipe:: packages
#

#
package 'postgres-8.4' do
  action :install
end
package 'libpq-dev' do
  action :install
end
package 'libpq5' do
  action :install
end
package 'libc6' do
  action :install
end
ackage 'libdbi-perl' do
  action :install
end


package 'libdbd-pg-perl' do
  action :install
end
p


package 'postgresql-plperl-8.4' do
  action :install
end
