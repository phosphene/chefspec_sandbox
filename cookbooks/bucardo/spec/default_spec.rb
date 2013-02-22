require 'chefspec'

describe 'bucardo::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'bucardo::default' }
  it 'should always install git-core' do
    chef_run.should install_package 'git-core'
  end

  it 'should checkout bucardo' do
    chef_run.git('checkout-bucardo').should be
  end
end
