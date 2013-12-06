require 'kitchen/provisioner/chef_base'

module Kitchen

  module Provisioner

    # Chef Client provisioner.
    class ChefClient < ChefBase

      def create_sandbox
        @tmpdir = Dir.mktmpdir("#{instance.name}-sandbox-")
        File.chmod(0755, @tmpdir)
        info("Preparing files for transfer")
        debug("Creating local sandbox in #{tmpdir}")

        yield if block_given?
        tmpdir
      end

      def install_command
        puts "Ignoring Install"
      end

      def run_command
        [
            sudo('chef-client'),
            "--log_level #{config[:log_level]}"
        ].join(" ")
      end

    end
  end
end
