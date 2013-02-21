#
# Cookbook Name:: bucardo
# Recipe:: packages
#

#
package 'libdbd-pg-perl' do
  action :install
end
package 'libdbi-perl' do
  action :install
end
package 'postgresql-plperl-8.4'
