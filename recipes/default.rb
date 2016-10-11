##
# Cookbook Name:: aws_opsworks_asset_precompile
# Recipe:: default
#
# Authored By: Stephen Reid
##

Chef::Log.info("# AWS Opsworks Asset Precompile #")

# Precompile assets. Assets are compiled into shared/assets and shared between deploys.
node[:deploy].each do |application, deploy|
  rails_env = deploy[:rails_env]
  Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")
  shared_path = "#{params[:path]}/shared"
  release_path = "#{deploy[:deploy_to]}/current"

  resources = [
    { release: "public/assets", shared: "assets"},
    { release: "node_modules", shared: "node_modules"}
  ]

  resources.each do |resource|
    # Erase the repositories public assets if they exist
    # We'll be creating new compiled assets
    directory "delete directory" do
      recursive true
      path "#{release_path}/#{resource[:release]}"
      action :delete
      only_if { ::File.directory?("#{release_path}/#{resource[:release]}") }
    end

    # create shared directory for assets, if it doesn't exist
    # if it already exists, then it will be smarter on only
    # changed files.
    directory "#{shared_path}/#{resource[:shared]}" do
      mode 0770
      action :create
      recursive true
    end

    # Symlink the release path to the shared path
    link "#{release_path}/#{resource[:release]}" do
      to "#{shared_path}/#{resource[:shared]}"
      only_if { ::File.directory?("#{shared_path}/#{resource[:shared]}") }
    end
  end

  execute "rake assets:precompile" do
    cwd release_path
    environment "RAILS_ENV" => rails_env
    environment "FOG_DIRECTORY" => deploy[:environment_variables]['FOG_DIRECTORY']
    environment "AWS_ACCESS_KEY" => deploy[:environment_variables]["AWS_ACCESS_KEY"]
    environment "AWS_SECRET_ACCESS_KEY" => deploy[:environment_variables]["AWS_SECRET_ACCESS_KEY"]
    command "RAILS_ENV=#{rails_env} FOG_DIRECTORY=#{deploy[:environment_variables]['FOG_DIRECTORY']} bundle exec rake assets:precompile"
  end
end
