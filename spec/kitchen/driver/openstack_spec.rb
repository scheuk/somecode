require 'ostruct'

describe Kitchen::Driver::Openstack do

  before {
    instance_suite.stub(:name => "suite_name")
    instance.stub(:name => "coolbeans", :logger => instance_logger, :suite => instance_suite, :busser => mock_busser)

    fta_driver.instance = instance
  }

  let(:logger_io) { StringIO.new }
  let(:mock_busser) {
    {
        ruby_bindir: "some_ruby_bin_dir"
    }
  }
  let(:instance_logger) { Kitchen::Logger.new(:logdev => logger_io) }

  let(:instance_suite) {
    double("instance_suite_mock")
  }

  let(:instance) {
    double("instance")
  }

  let(:mock_ssh_connection) {
    double("ssh_connection")
  }

  let(:config) {
    {}
  }

  subject(:fta_driver) {
    Kitchen::Driver::OpenstackFta.new(config)
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

  describe "#verify" do


    it "should download results and delete results on server" do

      Kitchen::SSH.should_receive(:new) {
        mock_ssh_connection
      }.exactly(2).times

      mock_ssh_connection.should_receive(:download_path!).with("serverspec_results.xml", ".")
      mock_ssh_connection.should_receive(:exec) { |cmd|
        expect(cmd).to include("rm -rf results")
      }
      mock_ssh_connection.should_receive(:shutdown)

      fta_driver.verify({})

    end

    it { should be_true }

    context "failure in super" do
      it "should still download" do

        @counter = 0
        Kitchen::SSH.should_receive(:new).exactly(2).times.and_return do
          @counter += 1
          raise Kitchen::ActionFailed.new("") if @counter == 1
          mock_ssh_connection
        end

        mock_ssh_connection.should_receive(:download_path!).with("serverspec_results.xml", ".")
        mock_ssh_connection.should_receive(:exec) { |cmd|
          expect(cmd).to include("rm -rf results")
        }
        mock_ssh_connection.should_receive(:shutdown)

        expect { fta_driver.verify({}) }.to raise_error(Kitchen::ActionFailed)
      end
    end
  end

  describe "#setup" do

    let(:mock_busser) {
      {
          ruby_bindir: "some_ruby_bin_dir",
          root_path: "some_busser_root"
      }
    }

    it "should setup yarjuf" do

      Kitchen::SSH.should_receive(:new) {
        mock_ssh_connection
      }.exactly(2).times

      mock_ssh_connection.should_receive(:exec) { |cmd|
        expect(cmd).to include("some_ruby_bin_dir/gem install yarjuf --no-rdoc --no-ri")
        expect(cmd).to include("BUSSER_ROOT=some_busser_root")
        expect(cmd).to include("GEM_HOME=some_busser_root/gems")
        expect(cmd).to include("GEM_PATH=$GEM_HOME")
        expect(cmd).to include("GEM_CACHE=$GEM_HOME/cache")
        expect(cmd).to include("PATH=$PATH:$GEM_HOME/bin")
      }
      mock_ssh_connection.should_receive(:shutdown)

      fta_driver.setup({})

    end

  end

end