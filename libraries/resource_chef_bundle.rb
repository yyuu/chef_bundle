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
        @deployment = nil
        @no_cache = false
        @no_prune = false
        @path = nil
        @without = []
        @with = []
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
            cmdline << "--path" << path.to_s
          end
          if without
            Array(without).each do |group|
              cmdline << "--without" << group.to_s
            end
          end
          if with
            Array(with).each do |group|
              cmdline << "--with" << group.to_s
            end
          end
        end
        if Chef::Platform.windows?
          @command = cmdline.join(" ")
        else
          require "shellwords"
          @command = Shellwords.shelljoin(cmdline)
        end
      end

      def compile_time(arg=nil)
        set_or_return(:compile_time, arg, :kind_of => [TrueClass, FalseClass])
      end

      def gemfile(arg=nil)
        set_or_return(:gemfile, arg, :kind_of => String, :required => true)
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
        if arg
          Array(arg).each do |group|
            validate({:without => group}, {:without => {:kind_of => String}})
          end
          @without += Array(arg)
        else
          @without
        end
      end

      def with(arg=nil)
        if arg
          Array(arg).each do |group|
            validate({:with => group}, {:with => {:kind_of => String}})
          end
          @with += Array(arg)
        else
          @with
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
