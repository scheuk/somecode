require 'ostruct'
describe Kitchen::Provisioner::ChefClient do

  let(:config) {
    nil
  }

  let(:chef_client) { Kitchen::Provisioner::ChefClient.new(OpenStruct.new({logger: nil}), config) }

  [:create_sandbox, :install_command].each do |method|
    describe "##{method}" do
      subject {chef_client.send(method)}

      it { should be_nil }
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