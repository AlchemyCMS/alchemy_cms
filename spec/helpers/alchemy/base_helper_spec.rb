require 'spec_helper'

module Alchemy
  describe BaseHelper do
    describe "#render_message" do
      context "if no argument is passed" do
        it "should render a div with an info icon and the given content" do
          expect(helper.render_message{ content_tag(:p, "my notice") }).to match(/<div class="info message"><span class="icon-info"><\/span><p>my notice/)
        end
      end

      context "if an argument is passed" do
        it "should render the passed argument as the css classname for the icon container" do
          expect(helper.render_message(:error){ content_tag(:p, "my notice") }).to match(/<div class="error message"><span class="icon-error">/)
        end
      end
    end

    describe '#page_or_find' do
      let(:page) { create(:alchemy_page, :public) }

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
