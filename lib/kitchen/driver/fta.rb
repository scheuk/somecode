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
        executeSSH(state) do |conn|
          run_remote("#{sudo} rm -rf #{busser_root}", conn)
        end
        puts "Destroyed #{busser_root} directory"
      end

    end

  end

end

