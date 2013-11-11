require 'kitchen/provisioner/chef_base'

module Kitchen

  module Provisioner

    # Chef Client provisioner.
    class ChefClient < ChefBase

      def create_sandbox
        puts "Ignoring Create Sandbox"
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
