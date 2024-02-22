# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe BaseHelper do
    describe "#render_icon" do
      subject { helper.render_icon(:info, options) }

      let(:options) { {} }

      it "renders an alchemy-icon with line style" do
        is_expected.to have_css 'alchemy-icon[name="information"][icon-style="line"]'
      end

      context "with options" do
        let(:options) { {style: "fill", size: "xl"} }

        it "renders an alchemy-icon with given options" do
          is_expected.to have_css 'alchemy-icon[name="information"][icon-style="fill"][size="xl"]'
        end
      end
    end

    describe "#render_message" do
      context "if no argument is passed" do
        it "should render a div with an info icon and the given content" do
          expect(helper.render_message { content_tag(:p, "my notice") }).to match(
            /<div class="info message"><alchemy-icon name="information" icon-style="line"><\/alchemy-icon><p>my notice/
          )
        end
      end

      context "if an argument is passed" do
        it "should render the passed argument as the css classname for the icon container" do
          expect(helper.render_message(:error) { content_tag(:p, "my notice") }).to match(
            /<div class="error message"><alchemy-icon name="bug" icon-style="line">/
          )
        end
      end
    end

    describe "#page_or_find" do
      let(:page) { create(:alchemy_page, :public) }

      context "passing a page_layout string" do
        context "of a not existing page" do
          it "should return nil" do
            expect(helper.page_or_find("contact")).to be_nil
          end
        end

        context "of an existing page" do
          it "should return the page object" do
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

    describe "#message_icon_class" do
      subject { helper.message_icon_class(message_type) }

      context "when `warning`, `warn` or `alert` message type is given" do
        %w[warning warn alert].each do |type|
          let(:message_type) { type }

          it { is_expected.to eq "exclamation" }
        end
      end

      context "when `notice` message type is given" do
        let(:message_type) { "notice" }

        it { is_expected.to eq "check" }
      end

      context "when `hint` message type is given" do
        let(:message_type) { "hint" }

        it { is_expected.to eq "info" }
      end

      context "when `error` message type is given" do
        let(:message_type) { "error" }

        it { is_expected.to eq "bug" }
      end

      context "when unknown message type is given" do
        let(:message_type) { "info" }

        it "returns the given message type as icon name" do
          is_expected.to eq "info"
        end
      end
    end
  end
end
