require 'chefspec'

describe 'bucardo::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'bucardo::default' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
