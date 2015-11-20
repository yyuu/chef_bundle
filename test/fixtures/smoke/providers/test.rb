def whyrun_supported?
  true
end

action :run do
  require "aws-sdk"
  Chef::Log.info("aws-sdk's config is #{Aws.config.inspect}")
end
