require 'json'

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
      default_config :check_for_idempotency, false
    end

    module FtaBase

      attr_reader :config

      def verify(state)
        super

        if (config[:check_for_idempotency])

          converge(state)
          super

          executeSSH(state) do |conn|
            run_remote("#{sudo} chmod -R 755 #{config[:chef_handler_json_source]}", conn)
            download_path(config[:chef_handler_json_source], config[:local_results_destination], conn)
          end

          latest_chef_run_file = "#{config[:local_results_destination]}/reports/#{find_latest_chef_run(Dir.entries("#{config[:local_results_destination]}/reports"))}"
          puts "Inspecting #{latest_chef_run_file} for idempotency"
          raise "Idempotency Failed!!!" unless verify_idempotency(latest_chef_run_file)
        end

      ensure
        executeSSH(state) do |conn|
          download_path(config[:remote_results_source], config[:local_results_destination], conn)
          run_remote("#{sudo} rm -rf results", conn)
        end
      end

      def verify_idempotency(chef_run_file_path)
        if (chef_run_file_path.nil?)
          puts 'Could not parse chef run report for idempotency, no chef run json file exists, verify your chef run list includes recipe[chef_handler::json_file]'
          return false
        end

        updated_resources = JSON.parse(File.open(chef_run_file_path, "r").read)['updated_resources']

        if (updated_resources.nil?)
          puts 'Could not parse chef run report for idempotency, it did not contain an updated_resources section'
          return false
        end

        updated_resources = filter_out_json_file_resource(updated_resources)

        puts "#{updated_resources.size()} updated resources (excluding json file handler resource)"

        updated_resources.size == 0
      rescue JSON::ParserError => e
        puts "Could not parse chef run report for idempotency due to \"#{e}\""
      end

      def filter_out_json_file_resource(updated_resources)
        updated_resources.select { |updated_resource|
          !is_json_file_resource(updated_resource)
        }
      end

      def is_json_file_resource(updated_resource)

        updated_resource.is_a?(Hash) &&
        updated_resource["instance_vars"]["recipe_name"] == "json_file" &&
            updated_resource["instance_vars"]["resource_name"] == "chef_handler" &&
            updated_resource["instance_vars"]["cookbook_name"] == "chef_handler" &&
            updated_resource["instance_vars"]["source"] == "chef/handler/json_file.rb"
      end

      def find_latest_chef_run(entries)
        found_chef_run = entries.map { |entry|
          match = /chef-run-report-(?<time_entry>\d*).json/.match(entry)
          {
              time_entry: match[:time_entry].to_i,
              file: entry

          } unless match.nil?
        }.select { |entry_map|
          !entry_map.nil?
        }.sort { |entry_map1, entry_map2|
          entry_map1[:time_entry] <=> entry_map2[:time_entry]
        }.reverse.first

        found_chef_run[:file] unless found_chef_run.nil?
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
          run_remote("#{sandbox_env} #{sudo}#{gem_bin} install yarjuf --no-rdoc --no-ri", conn)
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