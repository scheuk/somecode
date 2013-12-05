require 'ostruct'
describe Kitchen::Provisioner::ChefClient do

  let(:config) {
    {
        test_base_path: "some_test_path",
        kitchen_root: "some_kitchen_path"
    }
  }
  let(:logger_io) { StringIO.new }
  let(:instance_logger) { Kitchen::Logger.new(:logdev => logger_io) }
  let(:instance_suite) {
    double("instance_suite_mock")
  }
  let(:instance) {
    double("instance_mock")
  }

  let(:chef_client) do
    Kitchen::Provisioner::ChefClient.new(config)
  end

  before {
    instance_suite.stub(:name => "suite_name")
    instance.stub(:name => "coolbeans", :logger => instance_logger, :suite => instance_suite)
    chef_client.instance = instance
  }

  describe "#create_sandbox" do

    it "should not be empty" do
      chef_client.create_sandbox.should_not be_nil
    end

  end

  describe "#install_command" do

    it "sould be empty" do
      chef_client.install_command.should be_nil
    end

  end

  describe "#run_command" do

    subject { chef_client.run_command }

    let(:log_level) {
      "some_log_level"
    }

    context "with sudo" do
      let(:config) {
        {
            test_base_path: "some_test_path",
            kitchen_root: "some_kitchen_path",
            log_level: log_level,
            sudo: true
        }
      }

      it { should eq("sudo -E chef-client --log_level #{log_level}") }
    end

    context "without sudo" do
      let(:config) {
        {
            test_base_path: "some_test_path",
            kitchen_root: "some_kitchen_path",
            log_level: log_level,
            sudo: false
        }
      }

      it { should eq("chef-client --log_level #{log_level}") }
    end

  end

end