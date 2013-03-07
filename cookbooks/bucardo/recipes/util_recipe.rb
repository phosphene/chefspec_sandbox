package 'libxslt1-dev'
package 'libxml2-dev'
package 'libxml2'
package 'build_essential'


chef_gem 'fog'


require 'fog'    
# open the Chef::Recipe class and mix in the library module
class Chef::Recipe
  include UtilLib
end








