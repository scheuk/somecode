require 'rspec'
require 'yarjuf'
require 'kitchen/driver/fta'
require 'kitchen/provisioner/chef_client'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end
