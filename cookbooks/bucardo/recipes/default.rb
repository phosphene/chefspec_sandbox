include_recipe "bucardo::packages"
include_recipe "bucardo::included_recipe"

package 'git-core' do
  action :install
end


git "checkout-bucardo" do
  repository "git://github.com/phosphene/bucardo.git"
  reference "master"
  destination "/tmp/local"
end
