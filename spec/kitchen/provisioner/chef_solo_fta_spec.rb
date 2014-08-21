require 'ostruct'
require 'ohai'

describe Kitchen::Provisioner::ChefSoloFta do

  let(:config) {
    {
      attributes: {
        key1: {
          key1a: [
            "%%REPLACE_WITH_IP%%",
            "123.123.123.123"
          ],
          key1b: "%%REPLACE_WITH_IP%%"
        },
        key2: "%%REPLACE_WITH_IP%%"
      }
    }
  }
  let(:logger_io) { StringIO.new }
  let(:instance_logger) { Kitchen::Logger.new(:logdev => logger_io) }
  let(:instance_suite) {
    double("instance_suite_mock")
  }
  let(:mock_system) {
    double("mock_system")
  }

  let(:chef_client) do
    Kitchen::Provisioner::ChefSoloFta.new(config)
  end

  before {

    chef_client.hostname = '11.11.11.11'
  }

  describe "#inject_ip_address_into_attributes" do

    before { chef_client.inject_ip_address_into_attributes }

    it "should replace with ip" do
      chef_client[:attributes][:key1][:key1a].should eq([
                                                          "11.11.11.11",
                                                          "123.123.123.123"
                                                        ])
      chef_client[:attributes][:key1][:key1b].should eq("11.11.11.11")
      chef_client[:attributes][:key2].should eq("11.11.11.11")
    end

  end
end