require "chef/resource/execute"
require "rbconfig"
require "shellwords"

class Chef
  class Resource
    class ChefBundle < Chef::Resource::Execute

      provides :chef_bundle, :on_platforms => :all

      def initialize(name, run_context=nil)
        super
        @action = :install
        @allowed_actions += [:install]
        @resource_name = :chef_bundle
        @provider = Chef::Provider::Execute
      end

      def command(arg=nil)
        # Omnibus Chef Installer bundles bundler by default
        # TODO: install bundler if missing?
        bundle = ::File.join(::RbConfig::CONFIG["bindir"], "bundle")
        cmdline = [bundle]
        case @action
        when :install
          cmdline << "install"
          if gemfile
            cmdline << "--gemfile" << gemfile
          end
          if deployment
            cmdline << "--deployment"
          end
          if no_cache
            cmdline << "--no-cache"
          end
          if no_prune
            cmdline << "--no-prune"
          end
          if path
            cmdline << "--path" << path
          end
          if without
            cmdline << "--without" << without
          end
          if with
            cmdline << "--with" << with
          end
        end
        if Chef::Platform.windows?
          cmdline.join(" ")
        else
          Shellwords.shelljoin(cmdline)
        end
      end

      def gemfile(arg=nil)
        set_or_return(:gemfile, arg, :kind_of => String)
      end

      def deployment(arg=nil)
        set_or_return(:deployment, arg, :kind_of => [TrueClass, FalseClass])
      end

      def no_cache(arg=nil)
        set_or_return(:no_cache, arg, :kind_of => [TrueClass, FalseClass])
      end

      def no_prune(arg=nil)
        set_or_return(:no_prune, arg, :kind_of => [TrueClass, FalseClass])
      end

      def path(arg=nil)
        set_or_return(:path, arg, :kind_of => String)
      end

      def without(arg=nil)
        set_or_return(:without, arg, :kind_of => [String])
      end

      def with(arg=nil)
        set_or_return(:with, arg, :kind_of => [String])
      end

      def after_created()
        self.run_action(:run)
        Gem.clear_paths
      end
    end
  end
end
