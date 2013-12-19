describe Kitchen::Driver::FtaBase do
  let(:include_class) {
    Class.new do
      include Kitchen::Driver::FtaBase
    end
  }

  subject(:instance) {
    include_class.new
  }

  describe "#find_latest_chef_run" do

    let(:chef_run_files) {
      ["./reports/somefile.xml", "./reports/chef-run-report-1.json", "./reports/chef-run-report-10.json", "./reports/chef-run-report-2.json"]
    }

    subject {
      instance.find_latest_chef_run(chef_run_files)
    }

    it { should eq("./reports/chef-run-report-10.json") }

    describe "no matching files" do
      let(:chef_run_files) {
        ["./reports/somefile.xml"]
      }

      it { should be_nil }
    end
  end

  describe "#verify_idempotency" do
    let(:json_file) {
      "./reports/chef-run-report-1.json"
    }

    let(:mock_json_file) {
      double("json file")
    }

    let(:will_get_to_file_read) {
      true
    }

    before {
      if (will_get_to_file_read)
        mock_json_file.should_receive(:read) {
          mock_json_file_contents
        }

        File.should_receive(:open).with(json_file, "r") {
          mock_json_file
        }
      end
    }

    subject {
      instance.verify_idempotency(json_file)
    }

    describe "error conditions" do

      before {
        instance.should_receive(:puts).with(error_message)
      }

      describe "nil json file" do
        let(:json_file) {
          nil
        }

        let(:will_get_to_file_read) {
          false
        }

        let(:error_message) {
          'Could not parse chef run report for idempotency, no chef run json file exists, verify your chef run list includes recipe[chef_handler::json_file]'
        }

        it { should be_false }
      end

      describe "empty json" do
        let(:mock_json_file_contents) {
          ''
        }

        let(:error_message) {
          'Could not parse chef run report for idempotency due to "A JSON text must at least contain two octets!"'
        }

        it { should be_false }
      end

      describe "no updated resources block" do
        let(:mock_json_file_contents) {
          '{}'
        }

        let(:error_message) {
          'Could not parse chef run report for idempotency, it did not contain an updated_resources section'
        }

        it { should be_false }
      end
    end

    describe "no updated resources" do
      let(:mock_json_file_contents) {
        '{"updated_resources": []}'
      }

      it { should be_true }
    end

    describe "no updated resources, filter out json file handler" do
      let(:mock_json_file_contents) {

        "{\"updated_resources\": [
          #{File.read("#{File.dirname(__FILE__)}/JsonFileResource.json")}
        ]}"
      }

      it { should be_true }
    end

    describe "updated resources" do
      let(:mock_json_file_contents) {
        '{"updated_resources": ["could_be_anything"]}'
      }

      it { should be_false }
    end
  end
end