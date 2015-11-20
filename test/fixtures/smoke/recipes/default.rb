include_recipe "chef_bundle"

cookbook_file "/root/Gemfile" do
  source "Gemfile"
end.run_action(:create)

cookbook_file "/root/Gemfile.lock" do
  source "Gemfile.lock"
end.run_action(:create)

chef_bundle "aws-sdk" do
  gemfile "/root/Gemfile"
  without ["development", "test"]
end

smoke_test "aws-sdk"
