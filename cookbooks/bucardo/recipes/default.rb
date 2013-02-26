include_recipe "bucardo::packages"
include_recipe "bucardo::included_recipe"

package 'git-core' do
  action :install
end


git "checkout-bucardo" do
  repository "git://github.com/phosphene/bucardo.git"
  reference "master"
  destination "/tmp/local/bucardo_build"
end

extract_path = "/tmp/local/bucardo_build"
#if { ::File.exists?(extract_path) }

bash 'build_bucardo' do
  cwd ::File.dirname(extract_path)
  user 'root'
  group 'root'

  code <<-EOH
    perl Makefile.PL
    make
    make install
    EOH
  action :run
end
