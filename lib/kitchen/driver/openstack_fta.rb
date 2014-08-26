require 'kitchen/driver/fta_base'
require 'kitchen/driver/openstack'
require 'chef'

module Kitchen
  module Driver

    class OpenstackFta < Kitchen::Driver::Openstack
      include FtaBase

      def converge(state)

        if instance.provisioner.respond_to?(:hostname=)
          puts("Setting hostname, #{state[:hostname]}, on #{instance.provisioner}")
          instance.provisioner.hostname = state[:hostname]
        else
          puts("Provisioner, #{instance.provisioner}, does not support setting hostname, ignoring")
        end
        super
      end
    end

  end

end

