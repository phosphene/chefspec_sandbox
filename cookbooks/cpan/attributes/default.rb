node.default.cpan_client.default_inc = []
node.default.cpan_client.bootstrap.deps = [
 { :module => 'local::lib', :version => '0' },
 { :module => 'CPAN::Version', :version => '0' },
 { :module => 'ExtUtils::MakeMaker' , :version => '6.31' },
 { :module => 'Module::Build' , :version => '0.36_17' },
 { :module => 'Term::ReadLine::Perl' , :version => '0' },
 { :module => 'Term::ReadKey' , :version => '0' }
]

node.default.cpan_client.bootstrap.install_base = nil
node.default.cpan_client.minimal_version = '1.9800'
node.default.cpan_client.download_url = 'http://search.cpan.org/CPAN/authors/id/A/AN/ANDK/CPAN-1.9800.tar.gz'
