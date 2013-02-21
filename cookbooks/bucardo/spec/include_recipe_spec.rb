require 'bundler/setup'
require 'chefspec'

describe 'include_recipe tests' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'bucardo::include_recipes' }
  it 'includes another recipe' do
    chef_run.should include_recipe 'cpan'
  end
end
