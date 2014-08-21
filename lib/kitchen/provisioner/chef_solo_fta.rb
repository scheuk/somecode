require 'kitchen/provisioner/chef_solo'

module Kitchen

  module Provisioner

    # Chef Client provisioner.
    class ChefSoloFta < ChefSolo

      attr_accessor :hostname

      def run_command
        [
          super,
          "--environment kitchen-fta"
        ].join(" ")
      end

      def prepare_json

        inject_ip_address_into_attributes

        override_attributes = config[:attributes][:_override_attributes]

        super

        env_data = {
          name: 'kitchen-fta',
          description: 'environment for overriding attributes',
          default_attributes: {},
          json_class: 'Chef::Environment',
          chef_type: 'environment',
          override_attributes: override_attributes
        }

        Dir.mkdir("#{sandbox_path}/environments")

        File.open(File.join("#{sandbox_path}/environments", "kitchen-fta.json"), "wb") do |file|
          file.write(env_data.to_json)
        end
      end

      def inject_ip_address_into_attributes
        inject_ip_address(config[:attributes], hostname)
      end

      def inject_ip_address(attr_hash, ipaddress)

        attr_hash.each do |key, val|

          attr_hash[key] = ipaddress if val == "%%REPLACE_WITH_IP%%"

          attr_hash[key] = val.map { |item|
            if (item == "%%REPLACE_WITH_IP%%")
              ipaddress
            else
              item
            end
          } if val.is_a?(Array)


          inject_ip_address(val, ipaddress) if val.is_a?(Hash)
        end
      end

    end
  end
end