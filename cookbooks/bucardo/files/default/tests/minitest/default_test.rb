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

    # All of the matchers starting with 'must_' also have a negative 'wont_'.
    # So conversely we can also check that a file does not exist:
    it "ensures that the foobar file is removed if present" do
      directory("/tmp/foobar").wont_exist
    end

  end

end
