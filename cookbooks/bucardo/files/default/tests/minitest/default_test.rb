require 'minitest/spec'
#

# Spec:: default
#
#
describe_recipe 'bucardo::default' do

  #todo move to helper
  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  describe "dirs and files" do

    # = Testing that a file exists =
    #
    
    it "creates the bucardo build directory" do
      directory("/tmp/local/bucardo").must_exist
    end

    it "ensures that bucardo script is installed do
      file("/usr/local/bin/bucardo").must_exist
    end

  end

end
