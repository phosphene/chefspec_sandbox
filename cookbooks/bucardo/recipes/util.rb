gem_package 'fog'

# open the Chef::Recipe class and mix in the library module
class Chef::Recipe::Bucardo
  include Bucardo::Util
end







