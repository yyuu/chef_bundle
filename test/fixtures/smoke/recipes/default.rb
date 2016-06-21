include_recipe "chef_bundle"

cookbook_file "/root/custom-gemfile" do
  source "custom-gemfile"
end.run_action(:create)

cookbook_file "/root/custom-gemfile.lock" do
  source "custom-gemfile.lock"
end.run_action(:create)

chef_bundle "custom" do
  gemfile "/root/custom-gemfile"
  options ["--system", "--without", "development", "test"]
end

smoke_test "aws-sdk"
