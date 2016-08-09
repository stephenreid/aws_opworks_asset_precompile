require_relative '../spec_helper'

describe 'aws_opsworks_asset_precompile::default' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'creates the ohai hint' do
    expect(chef_run).to create_ohai_hint('ec2').at_compile_time
  end
end
