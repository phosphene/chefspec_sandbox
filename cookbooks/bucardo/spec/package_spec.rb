require 'chefspec'

describe 'bucardo::packages' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'bucardo::packages' }
  it 'should install plperl for postgres 8.4' do
    chef_run.should install_package 'postgresql-plperl-8.4'
  end

  it 'should install libdbd-pg-perl' do
    chef_run.should install_package 'libdbd-pg-perl'
  end

  it 'should install libdbi-perl' do
    chef_run.should install_package 'libdbd-pg-perl'
  end
end
