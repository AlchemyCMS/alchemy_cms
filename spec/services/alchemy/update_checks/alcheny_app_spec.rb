require "rails_helper"

RSpec.describe Alchemy::UpdateChecks::AlchemyApp, type: :model do
  before do
    WebMock.enable!
  end

  describe "#latest_version" do
    subject(:latest_version) { described_class.new(origin: "example.com").latest_version }

    context "requesting update-check endpoint" do
      before do
        stub_request(:post, "https://app.alchemy-cms.com/update-check")
          .to_return(
            status: 200,
            body: {latest_version: "2.6.0"}.to_json,
            headers: {"Content-Type" => "application/json"}
          )
      end

      it "returns latest stable version" do
        expect(latest_version).to eq("2.6.0")
      end
    end

    context "if update-check endpoint is unavailable" do
      before do
        stub_request(:post, "https://app.alchemy-cms.com/update-check").to_return(status: 503)
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
