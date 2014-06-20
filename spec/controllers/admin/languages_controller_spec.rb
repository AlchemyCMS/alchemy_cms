require 'spec_helper'

class Alchemy::Config;
end

describe Alchemy::Admin::LanguagesController, :type => :controller do

  before do
    sign_in(admin_user)
  end

  describe "new" do

    context "when default_language.page_layout is set" do
      it "should use it as page_layout-default for the new language" do
        # FML :/
        allow(Alchemy::Config).to receive(:get) do |arg|
          if arg == :default_language
            {'page_layout' => "new_standard"}
          else
            Alchemy::Config.show[arg.to_s]
          end
        end
        get :new
        expect(assigns(:language).page_layout).to eql("new_standard")
      end
    end

    context "when default_language or page_layout aren't configured" do
      it "should fallback to one configured in config.yml" do
        get :new
        expect(assigns(:language).page_layout).to eql("index")
      end
    end

  end
end
