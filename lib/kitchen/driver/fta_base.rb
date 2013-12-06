module Kitchen

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

  module Driver

    class SSHBase
      default_config :remote_results_source, "serverspec_results.xml"
      default_config :local_results_destination, "."
      default_config :chef_handler_json_source, "/var/chef/reports"
      default_config :chef_handler_json_source_file_mask, "chef-run-report-*.json"
      default_config :check_for_idempotency, false
    end

    module FtaBase

      attr_reader :config

      def verify(state)
        super
      ensure
        executeSSH(state) do |conn|
          #puts conn.class
          run_remote("#{sudo} chmod -R 755 #{config[:chef_handler_json_source]}", conn)
          download_path(config[:chef_handler_json_source], config[:local_results_destination], conn)

          download_path(config[:remote_results_source], config[:local_results_destination], conn)
          run_remote("rm -rf results", conn)
        end
      end

      def sudo
        config[:sudo] ? "sudo -E " : ""
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
        File.join(ruby_bin_path, 'gem')
      end

      def ruby_bin_path
        busser[:ruby_bindir]
      end

      def busser_root
        busser[:root_path]
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
end