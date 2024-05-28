require "rails_helper"

RSpec.describe "API Pages requests", type: :request do
  describe "GET /api/pages/:id" do
    let(:page) { create(:alchemy_page, :public) }

    subject do
      get("/api/pages/#{page.id}")
      response
    end

    let(:json) { JSON.parse(response.body) }

    context "with unauthorized user" do
      it "returns page JSON with site not included" do
        is_expected.to have_http_status(200)
        expect(json).to_not include("site")
      end

      it "returns page JSON with language not included" do
        is_expected.to have_http_status(200)
        expect(json).to_not include("language")
      end
    end

    context "with authorized user" do
      before do
        authorize_user(build(:alchemy_dummy_user, :as_author))
      end

      it "returns page JSON with site included" do
        is_expected.to have_http_status(200)
        expect(json).to include("site")
        expect(json["site"]).to include("id")
        expect(json["site"]).to include("name")
      end

      it "returns page JSON with language included" do
        is_expected.to have_http_status(200)
        expect(json).to include("language")
        expect(json["language"]).to include("id")
        expect(json["language"]).to include("name")
      end
    end
  end
end
