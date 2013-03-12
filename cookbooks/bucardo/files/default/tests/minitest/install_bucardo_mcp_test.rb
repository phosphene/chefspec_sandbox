require 'minitest/spec'
#

# Spec:: default
#
#
describe_recipe 'bucardo::install_bucardo_mcp' do

  #todo move to helper
  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  describe 'dirs and files' do

    # = Testing that a file exists =
    #
    
    it "creates the bucardo build directory" do
      directory("/tmp/local/bucardo_build").must_exist
    end

    it "ensures that bucardo script is installed" do
      file("/usr/local/bin/bucardo").must_exist
    end


    # if a file matches a regular expression:
    it "leaves pg_hba.conf in secure enough state" do
      file('/etc/postgresql/8.4/main/pg_hba.conf').must_match /local.*?#{node['bucardo']['slave']['user']}.*?ident$/
      file('/etc/postgresql/8.4/main/pg_hba.conf').wont_match /local.*?#{node['bucardo']['slave']['user']}.*?trust$/
    end



  end


end
