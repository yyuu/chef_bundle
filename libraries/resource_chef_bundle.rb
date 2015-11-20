require "chef/resource/execute"
require "rbconfig"

class Chef
  class Resource
    class ChefBundle < Chef::Resource::Execute
      provides :chef_bundle, :on_platforms => :all

      def initialize(name, run_context=nil)
        super(name, run_context)
        @action = :install
        @allowed_actions += [:install]
        @resource_name = :chef_bundle
        @compile_time = Chef::Config[:chef_gem_compile_time]
        @gemfile = nil
        @options = []
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
            cmdline << "--gemfile" << gemfile.to_s
          end
          Array(@options).each do |option|
            cmdline << option.to_s
          end
        end
        @command = cmdline.join(" ")
      end

      def compile_time(arg=nil)
        set_or_return(:compile_time, arg, :kind_of => [TrueClass, FalseClass])
      end

      def gemfile(arg=nil)
        set_or_return(:gemfile, arg, :kind_of => String, :required => true)
      end

      def options(arg=nil)
        if arg
          Array(arg).each do |option|
            validate({:options => option}, {:options => {:kind_of => String}})
          end
          @options = arg
        else
          @options
        end
      end

      def after_created()
        if compile_time or compile_time.nil?
          self.run_action(:run)
          Gem.clear_paths
        end
      end
    end
  end
end
