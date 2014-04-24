require 'kitchen/provisioner/chef_solo'

module Kitchen

  module Provisioner

    # Chef Client provisioner.
    class ChefSoloFta < ChefSolo

      def run_command
        [
          super,
          "--environment kitchen-fta"
        ].join(" ")
      end

      def prepare_json
        override_attributes = config[:attributes][:_override_attributes]
        config[:attributes].delete(:_override_attributes)

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

    end
  end
end