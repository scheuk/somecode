require 'kitchen/driver/fta_base'
require 'kitchen/driver/vagrant'

module Kitchen
  module Driver

    class VagrantFta < Kitchen::Driver::Vagrant
      include FtaBase
    end

  end

end

