# frozen_string_literal: true

RSpec.shared_examples_for "a controller that loads current language" do |args|
  context "when session has current language id key" do
    let!(:site_1) { create(:alchemy_site) }
    let!(:site_1_default_language) { create :alchemy_language, site: site_1, default: true }
    let!(:another_site_1_language) { create :alchemy_language, site: site_1, code: :de }
    let(:site_2) { create :alchemy_site, host: "another.host", languages: [build(:alchemy_language, code: :en), build(:alchemy_language, code: :de)] }

    before { session[:alchemy_language_id] = another_site_1_language.id }

    context "when language ID in session is associated with the current site" do
      it "sets @current_language" do
        get :index, params: {site_id: site_1.id}
        expect(assigns(:current_language)).to eq(another_site_1_language)
      end
    end

    context "when language ID in session is not associated with the current site" do
      it "sets @current_language to the current site default language" do
        get :index, params: {site_id: site_2.id}
        expect(assigns(:current_language)).to eq(site_2.default_language)
      end

      it "does not change the language ID in session" do
        expect { get :index, params: {site_id: site_2.id} }.not_to change { session[:alchemy_language_id] }
      end
    end

    context "when no language ID in session" do
      before { session[:alchemy_language_id] = nil }

      it "sets @current_language to language language" do
        get :index, params: {site_id: site_2.id}
        expect(assigns(:current_language)).to eq site_2.default_language
      end
    end

    context "when no language to set" do
      it "shows flash warning with redirect" do
        Alchemy::Language.destroy_all
        get :index, params: {site_id: site_1.id}
        expect(flash[:warning]).to eq Alchemy.t("Please create a language first.")
        expect(response).to redirect_to admin_languages_path
      end
    end
  end
end
