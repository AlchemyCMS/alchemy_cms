require 'spec_helper'

module Alchemy
  describe BaseHelper do

    describe "#render_message" do
      context "if no argument is passed" do
        it "should render a div with an info icon and the given content" do
          expect(helper.render_message{ content_tag(:p, "my notice") }).to match(/<div class="info message"><span class="icon info"><\/span><p>my notice/)
        end
      end

      context "if an argument is passed" do
        it "should render the passed argument as the css classname for the icon container" do
          expect(helper.render_message(:error){ content_tag(:p, "my notice") }).to match(/<div class="error message"><span class="icon error">/)
        end
      end
    end

    describe "#configuration" do
      it "should return certain configuration options" do
        allow(Config).to receive(:show).and_return({"some_option" => true})
        expect(helper.configuration(:some_option)).to eq(true)
      end
    end

    describe "#multi_language?" do
      context "if more than one published language exists" do
        it "should return true" do
          allow(Alchemy::Language).to receive(:published).and_return double(count: 2)
          expect(helper.multi_language?).to eq(true)
        end
      end

      context "if less than two published languages exists" do
        it "should return false" do
          allow(Alchemy::Language).to receive(:published).and_return double(count: 1)
          expect(helper.multi_language?).to eq(false)
        end
      end
    end

    describe '#breadcrumb' do
      let(:lang_root) { Page.language_root_for(Language.default.id) }
      let(:parent)    { FactoryGirl.create(:public_page) }
      let(:page)      { FactoryGirl.create(:public_page, parent_id: parent.id) }

      it "returns an array of all parents including self" do
        expect(helper.breadcrumb(page)).to eq([lang_root, parent, page])
      end

      it "does not include the root page" do
        expect(helper.breadcrumb(page)).not_to include(Page.root)
      end

      context "with current page nil" do
        it "should return an empty array" do
          expect(helper.breadcrumb(nil)).to eq([])
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
