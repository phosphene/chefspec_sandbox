include_recipe 'cpan'

puts "node is #{node.attributes.inspect}"

ruby_block 'load_cpan_attributes' do
  block do
    node.load_attribute_by_short_filename('default', 'cpan')
  end
end

resources(:ruby_block => "load_cpan_attributes")

puts "node is #{node.inspect}"
upgrade_command = 'rm -rf /tmp/cpan-client-download/ && mkdir -p /tmp/cpan-client-download/ '
upgrade_command << " && cd /tmp/cpan-client-download/ && wget #{node.cpan_client.download_url} "
upgrade_command << ' && tar -zxf *.tar.gz  && cd *.* '
upgrade_command << ' && perl Makefile.PL && make && make test && make install'

execute 'upgrade cpan client to proper version' do
    command upgrade_command
    not_if "perl -e 'use CPAN #{node.cpan_client.minimal_version}'"
end

node.cpan_client.bootstrap.deps.each  do |m|
    cpan_client m[:module] do
        user 'root'
        group 'root'
        install_type 'cpan_module'
        version m[:version]
        action 'install'
        install_base node.cpan_client.bootstrap.install_base
        environment({'AUTOMATED_TESTING' => '1'})
    end
end
