require 'rspec'
require 'yarjuf'
require 'kitchen/driver/fta'
require 'kitchen/driver/fta_base'
require 'kitchen/driver/openstack_fta'
require 'kitchen/provisioner/chef_client'
require 'kitchen/provisioner/chef_solo_fta'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end
