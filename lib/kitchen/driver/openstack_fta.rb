require 'kitchen/driver/fta_base'
require 'kitchen/driver/openstack'

module Kitchen
  module Driver

    class OpenstackFta < Kitchen::Driver::Openstack
      include FtaBase
    end

  end

end

