require 'ostruct'
describe Kitchen::Provisioner::ChefClient do

  let(:config) { Hash.new }
  let(:logger_io) { StringIO.new }
  let(:instance_logger) { Kitchen::Logger.new(:logdev => logger_io) }
  let(:instance_suite) {stub(:name => "suite_name")}
  let(:instance) {
    stub(:name => "coolbeans", :logger => instance_logger, :suite => "blah")
  }

  let(:chef_client) do
    p = Kitchen::Provisioner::ChefClient.new(config)
    #p.instance = instance
    p
  end

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


    context "with sudo" do
      let(:config) {
        {
            log_level: log_level,
            sudo: true
        }
      }

      it { should eq("sudo -E chef-client --log_level some_log_level") }
    end

    context "without sudo" do
      let(:config) {
        {
            log_level: log_level,
            sudo: false
        }
      }

      it { should eq("chef-client --log_level some_log_level") }
    end

  end

end