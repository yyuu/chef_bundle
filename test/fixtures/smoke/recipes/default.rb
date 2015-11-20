include_recipe "chef_bundle"

cookbook_file "/root/aws-gemfile" do
  source "aws-gemfile"
end.run_action(:create)

cookbook_file "/root/aws-gemfile.lock" do
  source "aws-gemfile.lock"
end.run_action(:create)

chef_bundle "aws-sdk" do
  gemfile "/root/aws-gemfile"
  options ["--system", "--without", "development", "test"]
end

smoke_test "aws-sdk"
