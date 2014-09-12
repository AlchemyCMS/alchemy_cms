require 'spec_helper'

describe Alchemy::Admin::LanguagesController do

  before do
    authorize_user(:as_admin)
  end

  describe "#new" do
    context "when default_language.page_layout is set" do
      before do
        allow(Alchemy::Config).to receive(:get) do |arg|
          if arg == :default_language
            {'page_layout' => "new_standard"}
          else
            Alchemy::Config.show[arg.to_s]
          end
        end
      end

      it "uses it as page_layout-default for the new language" do
        alchemy_get :new
        expect(assigns(:language).page_layout).to eq("new_standard")
      end
    end

    context "when default_language is not configured" do
      before do
        allow(Alchemy::Config).to receive(:get) do |arg|
          if arg == :default_language
            nil
          else
            Alchemy::Config.show[arg.to_s]
          end
        end
      end

      it "falls back to default database value." do
        alchemy_get :new
        expect(assigns(:language).page_layout).to eq("intro")
      end
    end

    context "when default language page_layout is not configured" do
      before do
        allow(Alchemy::Config).to receive(:get) do |arg|
          if arg == :default_language
            {}
          else
            Alchemy::Config.show[arg.to_s]
          end
        end
      end

      it "falls back to default database value." do
        alchemy_get :new
        expect(assigns(:language).page_layout).to eq("intro")
      end
    end
  end

  describe '#switch' do
    let!(:language) { Alchemy::Language.default }

    before { request.stub(referer: '/admin/pages') }

    it "sets the new language id in sessions" do
      get :switch, language_id: language.id
      expect(session[:alchemy_language_id]).to eq(language.id)
    end

    it "redirects to referer" do
      get :switch, language_id: language.id
      expect(response).to redirect_to('/admin/pages')
    end
  end
end
