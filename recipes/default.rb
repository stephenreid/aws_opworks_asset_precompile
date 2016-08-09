##
# Cookbook Name:: aws_opsworks_asset_precompile
# Recipe:: default
#
# Authored By: Stephen Reid
##

rails_env = ENV["RAILS_ENV"]
Chef::Log.info("# AWS Opsworks Asset Precompile #")
Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")

# Precompile assets. Assets are compiled into shared/assets and shared between deploys.
shared_path = "#{new_resource.deploy_to}/shared"
resources = [
	{ release: "public/assets", shared: "assets"},
	{ release: "node_modules", shared: "node_modules"},
]

resources.each do |resource|
	# Erase the repositories public assets if they exist
	# We'll be creating new compiled assets
	directory "delete directory" do
	  recursive true
	  path "#{release_path}/#{resource[:release]}"
	  action :delete
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
	end
end


execute "npm install" do
	cwd release_path
	environment "RAILS_ENV" => rails_env
	command "npm install --production"
end

execute "rake assets:precompile" do
	cwd release_path
	environment "RAILS_ENV" => ENV["RAILS_ENV"]
	environment "FOG_DIRECTORY" => ENV"FOG_DIRECTORY"]
	environment "AWS_ACCESS_KEY" => ENV["AWS_ACCESS_KEY"]
	environment "AWS_SECRET_ACCESS_KEY" => ENV["AWS_SECRET_ACCESS_KEY"]
	command "bundle exec rake assets:precompile"
end
