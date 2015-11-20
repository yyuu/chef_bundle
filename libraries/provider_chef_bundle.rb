require "chef/resource/execute"

class Chef
  class Provider
    class ChefBundle < Chef::Provider::Execute
      provides :chef_bundle

      alias_method :action_install, :action_run
    end
  end
end
