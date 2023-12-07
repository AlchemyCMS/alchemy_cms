# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe BaseHelper do
    describe "#render_icon" do
      subject { helper.render_icon(:info, options) }

      let(:options) { {} }

      it "renders a solid remix icon with fixed width and line style" do
        is_expected.to have_css "i.icon.ri-information-line.ri-fw"
      end

      context "with style set to fill" do
        let(:options) { {style: "fill"} }

        it "renders a filled remix icon" do
          is_expected.to have_css 'i[class*="-fill"]'
        end
      end

      context "with fixed_width set to false" do
        let(:options) { {fixed_width: false} }

        it "renders a default width remix icon" do
          is_expected.to have_css "i.icon.ri-information-line"
        end
      end

      context "with style set to nil" do
        let(:options) { {style: nil} }

        it "renders a remix icon without style" do
          is_expected.to have_css "i.icon.ri-information.ri-fw"
        end
      end

      context "with size set to xs" do
        let(:options) { {size: "xs"} }

        it "renders a extra small remix icon" do
          is_expected.to have_css "i.ri-xs"
        end
      end

      context "with class option given" do
        let(:options) { {class: "disabled"} }

        it "renders a remix icon with additional css class" do
          is_expected.to have_css "i.disabled"
        end
      end
    end

    describe "#render_message" do
      context "if no argument is passed" do
        it "should render a div with an info icon and the given content" do
          expect(helper.render_message { content_tag(:p, "my notice") }).to match(
            /<div class="info message"><i class="icon ri-information-line ri-fw"><\/i><p>my notice/
          )
        end
      end

      context "if an argument is passed" do
        it "should render the passed argument as the css classname for the icon container" do
          expect(helper.render_message(:error) { content_tag(:p, "my notice") }).to match(
            /<div class="error message"><i class="icon ri-bug-line ri-fw">/
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

    describe "#ri_icon" do
      subject { helper.send(:ri_icon, icon_name) }

      context "when `minus`, `remove` or `delete` icon name is given" do
        %w[minus remove delete].each do |type|
          let(:icon_name) { type }

          it { is_expected.to eq "delete-bin-2" }
        end
      end

      context "when `plus` icon name is given" do
        let(:icon_name) { "plus" }

        it { is_expected.to eq "add" }
      end

      context "when `copy` icon name is given" do
        let(:icon_name) { "copy" }

        it { is_expected.to eq "file-copy" }
      end

      context "when `download` icon name is given" do
        let(:icon_name) { "download" }

        it { is_expected.to eq "download-2" }
      end

      context "when `upload` icon name is given" do
        let(:icon_name) { "upload" }

        it { is_expected.to eq "upload-2" }
      end

      context "when `exclamation` icon name is given" do
        let(:icon_name) { "exclamation" }

        it { is_expected.to eq "alert" }
      end

      context "when `info` or `info-circle` icon name is given" do
        %w[info info-circle].each do |type|
          let(:icon_name) { type }

          it { is_expected.to eq "information" }
        end
      end

      context "when `times` icon name is given" do
        let(:icon_name) { "times" }

        it { is_expected.to eq "close" }
      end

      context "when `tag` icon name is given" do
        let(:icon_name) { "tag" }

        it { is_expected.to eq "price-tag-3" }
      end

      context "when `cog` icon name is given" do
        let(:icon_name) { "cog" }

        it { is_expected.to eq "settings-3" }
      end

      context "when unknown icon name is given" do
        let(:icon_name) { "foo" }

        it "returns the given icon name" do
          is_expected.to eq "foo"
        end
      end
    end
  end
end
