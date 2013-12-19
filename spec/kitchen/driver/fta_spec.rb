require 'ostruct'
describe Kitchen::Driver::Fta do

  BUSSER_ROOT = "/some/busser/path"
  RUBY_BIN = "/some/ruby/bin/path"

  before {
    @mock_ssh_connection = double("ssh_connection")

    fta_driver.instance = double("instance mock")
    fta_driver.instance.stub(:logger) { mock_logger }
    fta_driver.instance.stub(:busser) { mock_busser }

    mock_busser.stub(:[]).with(:root_path) {
      BUSSER_ROOT
    }
    mock_busser.stub(:[]).with(:ruby_bindir) {
      RUBY_BIN
    }

    mock_logger.stub(:info) { true }
  }

  let(:mock_logger) {
    double("mock logger")
  }

  let(:mock_busser) {
    double("mock busser")
  }

  let(:config) {
    {}
  }

  subject(:fta_driver) {
    Kitchen::Driver::Fta.new(config)
  }

  describe "#config" do

    subject {
      fta_driver.config
    }

    its(:to_hash) { should include(:remote_results_source => "serverspec_results.xml") }
    its(:to_hash) { should include(:local_results_destination => ".") }

    context "override keys" do
      let (:config) {
        {
            :remote_results_source => "some_other.xml",
            :local_results_destination => "some_other_destination"
        }
      }

      its(:to_hash) { should include(:remote_results_source => "some_other.xml") }
      its(:to_hash) { should include(:local_results_destination => "some_other_destination") }
    end

  end

  describe "#create" do
    subject {
      fta_driver.create(nil)
    }

    it { should be_true }
  end

  describe "#destroy" do
    before {
      Kitchen::SSH.should_receive(:new) {
        @mock_ssh_connection
      }.exactly(1).times

      @mock_ssh_connection.should_receive(:exec) { |cmd|
        expect(cmd).to include("rm -rf #{BUSSER_ROOT}")
      }

      @mock_ssh_connection.should_receive(:shutdown)
    }

    subject {
      fta_driver.destroy({})
    }

    it { should be_true }

  end

  describe "#verify" do


    it "should download results and delete results on server" do

      Kitchen::SSH.should_receive(:new) {
        @mock_ssh_connection
      }.exactly(2).times

      @mock_ssh_connection.should_receive(:download_path!).with("serverspec_results.xml", ".")
      @mock_ssh_connection.should_receive(:exec) { |cmd|
        expect(cmd).to include("rm -rf results")
      }
      @mock_ssh_connection.should_receive(:shutdown)

      fta_driver.verify({})

    end

    it { should be_true }

    context "failure in super" do
      it "should still download" do

        @counter = 0
        Kitchen::SSH.should_receive(:new).exactly(2).times.and_return do
          @counter += 1
          raise Kitchen::ActionFailed.new("") if @counter == 1
          @mock_ssh_connection
        end

        @mock_ssh_connection.should_receive(:download_path!).with("serverspec_results.xml", ".")
        @mock_ssh_connection.should_receive(:exec) { |cmd|
          expect(cmd).to include("rm -rf results")
        }
        @mock_ssh_connection.should_receive(:shutdown)

        expect { fta_driver.verify({}) }.to raise_error(Kitchen::ActionFailed)
      end
    end
  end

  describe "#setup" do

    before {

    }

    it "should setup yarjuf" do

      Kitchen::SSH.should_receive(:new) {
        @mock_ssh_connection
      }.exactly(2).times

      @mock_ssh_connection.should_receive(:exec) { |cmd|
        expect(cmd).to include("#{RUBY_BIN}/gem install yarjuf --no-rdoc --no-ri")
        expect(cmd).to include("BUSSER_ROOT=#{BUSSER_ROOT}")
        expect(cmd).to include("GEM_HOME=#{BUSSER_ROOT}/gems")
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