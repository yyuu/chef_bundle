require "chef/resource/execute"

class Chef
  class Provider
    class ChefBundle < Chef::Provider::Execute
      if respond_to?(:provides) # chef < 12
        provides :chef_bundle
      end

      alias_method :action_install, :action_run
    end
  end
end
