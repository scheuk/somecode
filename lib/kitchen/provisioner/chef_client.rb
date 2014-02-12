require 'kitchen/provisioner/chef_base'

module Kitchen

  module Provisioner

    # Chef Client provisioner.
    class ChefClient < ChefBase

      def create_sandbox
        @sandbox_path = Dir.mktmpdir("#{instance.name}-sandbox-")
        File.chmod(0755, sandbox_path)
        info("Preparing files for transfer")
        debug("Creating local sandbox in #{sandbox_path}")
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
