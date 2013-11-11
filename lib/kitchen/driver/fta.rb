require 'kitchen'

module Kitchen
  module Driver

    class Fta < Kitchen::Driver::SSHBase

      def create(state)
        puts "Ignoring Create"
      end

      def destroy(state)
        puts "Ignoring Destroy"
      end


      def verify(state)
        super

        executeSSH(state) do |conn|
          download_path("results", "tmp", conn)
          run_remote("rm -rf results", conn)
        end
      end

      def executeSSH(state)
        conn = Kitchen::SSH.new(*build_ssh_args(state))
        yield conn
        conn.shutdown
      end

      def setup(state)
        super

        executeSSH(state) do |conn|
          run_remote("#{sandbox_env} #{gem_bin} install yarjuf --no-rdoc --no-ri", conn)
        end

      end

      def gem_bin
        File.join(ruby_bin_path(), 'gem')
      end

      def ruby_bin_path
        config.fetch(:ruby_binpath, "/opt/chef/embedded/bin")
      end

      def busser_root
        config.fetch(:busser_root, "/tmp/kitchen-busser")
      end

      def sandbox_env(export=false)
        env = [
            "BUSSER_ROOT=#{busser_root}",
            "GEM_HOME=#{busser_root}/gems",
            "GEM_PATH=$GEM_HOME",
            "GEM_CACHE=$GEM_HOME/cache",
            "PATH=$PATH:$GEM_HOME/bin"
        ]

        if export
          env << "; export BUSSER_ROOT GEM_HOME GEM_PATH GEM_CACHE PATH;"
        end

        env.join(" ")
      end

      def download_path(remote, local, connection)
        return if remote.nil?

        connection.download_path!(remote, local)
      rescue SSHFailed, Net::SSH::Exception => ex
        raise ActionFailed, ex.message
      end

    end

  end
#
  class SSH
    attr_writer :session

    def download!(remote, local, options = {}, &progress)
      if progress.nil?
        progress = lambda { |ch, name, sent, total|
          if sent == total
            logger.info("Downloaded #{name} (#{total} bytes)")
          end
        }
      end

      session.scp.download!(remote, local, options, &progress)
    end

    def download_path!(remote, local, options = {}, &progress)
      options = {:recursive => true}.merge(options)

      download!(remote, local, options, &progress)
    end
  end
end

