require 'kitchen'
require 'kitchen/driver/fta_base'

module Kitchen
  module Driver

    class Fta < Kitchen::Driver::SSHBase

      include FtaBase

      def create(state)
        puts "Ignoring Create"
      end

      def destroy(state)
        puts "Ignoring Destroy"
      end

    end

  end

end

