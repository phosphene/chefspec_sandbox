require 'chefspec'

describe 'bucardo::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'bucardo::default' }

  it 'should always install git-core' do
    chef_run.should install_package 'git-core'
  end

  it 'should checkout bucardo' do
    chef_run.git('checkout-bucardo').should be
  end


  it 'includes includedrecipe' do
    chef_run.should include_recipe 'bucardo::included_recipe'
  end

  it 'mods pg_conf' do
    chef_run = ChefSpec::ChefRunner.new
    chef_run.node.set['bucardo']['user'] = 'bucardo'
    chef_run.converge('bucardo::default')
  end


end
