require "rails_helper"

RSpec.describe Alchemy::UpdateChecks::RubyGems, type: :model do
  before do
    WebMock.enable!
  end

  describe "#latest_version" do
    subject(:latest_version) { described_class.new(origin: nil).latest_version }

    context "requesting update-check endpoint" do
      before do
        stub_request(:get, "https://rubygems.org/api/v1/versions/alchemy_cms.json")
          .to_return(
            status: 200,
            body: [
              {
                number: "8.0.0.c",
                prerelease: true
              },
              {
                number: "7.4.11",
                prerelease: false
              }
            ].to_json,
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "returns latest stable version" do
        expect(latest_version).to eq("7.4.11")
      end
    end

    context "if update-check endpoint is unavailable" do
      before do
        stub_request(:get, "https://rubygems.org/api/v1/versions/alchemy_cms.json").to_return(status: 503)
      end

      it "should raise error" do
        expect { latest_version }.to raise_error(Alchemy::UpdateServiceUnavailable)
      end
    end
  end

  after do
    WebMock.disable!
  end
end
