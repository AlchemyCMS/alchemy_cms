# frozen_string_literal: true

RSpec.shared_examples_for "a controller that loads current language" do |args|
  context "when session has current language id key" do
    let!(:site_1) { create(:alchemy_site) }
    let!(:site_1_default_language) { create :alchemy_language, site: site_1, default: true }
    let!(:another_site_1_language) { create :alchemy_language, site: site_1, code: :de }
    let(:site_2) { create :alchemy_site, host: "another.host", languages: [build(:alchemy_language, code: :en), build(:alchemy_language, code: :de)] }

    context "on index action" do
      context "when switching the current site" do
        before do
          session[:alchemy_site_id] = site_1.id
          session[:alchemy_language_id] = another_site_1_language.id
        end

        it "sets @current_language to the new site default language" do
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
end
