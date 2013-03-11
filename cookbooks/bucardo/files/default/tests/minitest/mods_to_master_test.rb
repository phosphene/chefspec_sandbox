require 'minitest/spec'
#

# Spec:: default
#
#
describe_recipe 'bucardo::mods_to_master' do

  #todo move to helper
  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  describe 'dirs and files' do

  
    # if a file matches a regular expression:
    it "adds remote user to pg_hba.conf" do
      file('/etc/postgresql/8.4/main/pg_hba.conf').must_match /hostssl.*?#{node['bucardo']['slave']['user']}.*?md5$/
      file('/etc/postgresql/8.4/main/pg_hba.conf').wont_match /hostssl.*?#{node['bucardo']['slave']['user']}.*?trust$/
    end

    # if a file matches a regular expression:
    it "adds listen to postgresql.conf" do
      file('/etc/postgresql/8.4/main/postgresql.conf').must_match /^listen_addresses\s=\s'\*'$/
      file('/etc/postgresql/8.4/main/postgresql.conf').wont_match /^\#listen_addresses\s=\s'localhost'$/
    end


  end


end
