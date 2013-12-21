require 'spec_helper'

module Alchemy
  describe BaseHelper do

    describe "#render_message" do
      context "if no argument is passed" do
        it "should render a div with an info icon and the given content" do
          helper.render_message{ content_tag(:p, "my notice") }.should match(/<div class="info message"><span class="icon info"><\/span><p>my notice/)
        end
      end

      context "if an argument is passed" do
        it "should render the passed argument as the css classname for the icon container" do
          helper.render_message(:error){ content_tag(:p, "my notice") }.should match(/<div class="error message"><span class="icon error">/)
        end
      end
    end

    describe "#configuration" do
      it "should return certain configuration options" do
        Config.stub(:show).and_return({"some_option" => true})
        helper.configuration(:some_option).should == true
      end
    end

    describe "#multi_language?" do
      context "if more than one published language exists" do
        it "should return true" do
          Alchemy::Language.stub_chain(:published, :count).and_return(2)
          helper.multi_language?.should == true
        end
      end

      context "if less than two published languages exists" do
        it "should return false" do
          Alchemy::Language.stub_chain(:published, :count).and_return(1)
          helper.multi_language?.should == false
        end
      end
    end

    describe '#breadcrumb' do
      let(:lang_root) { Page.language_root_for(Language.default.id) }
      let(:parent)    { FactoryGirl.create(:public_page) }
      let(:page)      { FactoryGirl.create(:public_page, parent_id: parent.id) }

      it "returns an array of all parents including self" do
        helper.breadcrumb(page).should == [lang_root, parent, page]
      end

      it "does not include the root page" do
        helper.breadcrumb(page).should_not include(Page.root)
      end

      context "with current page nil" do
        it "should return an empty array" do
          helper.breadcrumb(nil).should == []
        end
      end
    end

    describe '#page_or_find' do
      let(:page) { FactoryGirl.create(:public_page) }

      context "passing a page_layout string" do
        context "of a not existing page" do
          it "should return nil" do
            expect(helper.page_or_find('contact')).to be_nil
          end
        end

        context 'of an existing page' do
          it "should return the page object" do
            session[:alchemy_language_id] = page.language_id
            expect(helper.page_or_find(page.page_layout)).to eq(page)
          end
        end
      end

      context "passing a page object" do
        it "should return the given page object" do
          expect(helper.page_or_find(page)).to eq(page)
        end
      end

    end

  end
end
