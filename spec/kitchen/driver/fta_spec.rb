require 'ostruct'
describe Kitchen::Driver::Fta do

  before {
    @mock_ssh_connection = double("ssh_connection")
  }

  let(:config) {
    {}
  }

  subject(:fta_driver) {
    Kitchen::Driver::Fta.new(config)
  }

  [:create, :destroy].each do |method|
    describe "##{method}" do
      subject { fta_driver.send(method, nil) }
      it { should be_true }
    end
  end

  describe "#create" do
    subject {
      fta_driver.create(nil)
    }

    it { should be_true }
  end

  describe "#destroy" do
    subject {
      fta_driver.destroy(nil)
    }

    it { should be_true }
  end

  describe "#verify" do


    it "should download results and delete results on server" do

      Kitchen::SSH.should_receive(:new) {
        @mock_ssh_connection
      }.exactly(2).times

      @mock_ssh_connection.should_receive(:download_path!).with("results", "tmp")
      @mock_ssh_connection.should_receive(:exec) { |cmd|
        expect(cmd).to include("rm -rf results")
      }
      @mock_ssh_connection.should_receive(:shutdown)

      fta_driver.verify({})

    end

    it { should be_true }
  end

  describe "#setup" do

    let(:config) {
      {busser_root:"some_busser_root"}
    }
    it "should setup yarjuf" do

      Kitchen::SSH.should_receive(:new) {
        @mock_ssh_connection
      }.exactly(2).times

      @mock_ssh_connection.should_receive(:exec) { |cmd|
        expect(cmd).to include("/opt/chef/embedded/bin/gem install yarjuf --no-rdoc --no-ri")
        expect(cmd).to include("BUSSER_ROOT=some_busser_root")
        expect(cmd).to include("GEM_HOME=some_busser_root/gems")
        expect(cmd).to include("GEM_PATH=$GEM_HOME")
        expect(cmd).to include("GEM_CACHE=$GEM_HOME/cache")
        expect(cmd).to include("PATH=$PATH:$GEM_HOME/bin")
      }
      @mock_ssh_connection.should_receive(:shutdown)

      fta_driver.setup({})

    end

  end

end

describe Kitchen::SSH do

  before {
    @ssh_driver = Kitchen::SSH.new(nil, nil)
    @scp_mock = double("scp")
    @ssh_driver.session = OpenStruct.new({scp: @scp_mock})
  }

  describe "#download_path" do

    it "should receive download!" do
      @scp_mock.should_receive(:download!).with("remote_path", "local_path", {recursive: true, some_key: "some_val"})

      @ssh_driver.download_path!("remote_path", "local_path", {some_key: "some_val"})
    end

  end

end