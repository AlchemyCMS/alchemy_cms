require 'spec_helper'

class Alchemy::Config;
end

describe Alchemy::Admin::LanguagesController do

  before do
    sign_in(admin_user)
  end

  describe "new" do

    context "when default_language.page_layout is set" do
      it "should use it as page_layout-default for the new language" do
        Alchemy::Config.should_receive(:get).with(:default_language) { {'page_layout' => "new_standard"} }
        get :new
        assigns(:language).page_layout.should eql("new_standard")
      end
    end

    context "when default_language or page_layout aren't configured" do
      it "should fallback to 'intro'" do
        get :new
        assigns(:language).page_layout.should eql("intro")
      end
    end

  end
end