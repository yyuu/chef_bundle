require "serverspec"

set :backend, :exec

describe package("aws-sdk") do
  it { should be_installed.by("gem").with_version("2.2.1") }
end
