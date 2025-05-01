# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::BaseHelper do
    describe "#link_to_dialog" do
      it "renders a alchemy-dialog-link" do
        link = helper.link_to_dialog("Open", admin_dashboard_path)
        expect(link).to have_css %(a[href="#{admin_dashboard_path}"][is="alchemy-dialog-link"])
      end

      it "passes options to alchemy-dialog-link" do
        link = helper.link_to_dialog("Open", admin_dashboard_path, {size: "800x600"})
        expect(link).to match %(data-dialog-options="{&quot;modal&quot;:true,&quot;size&quot;:&quot;800x600&quot;}")
      end

      it "passes html options to alchemy-dialog-link" do
        link = helper.link_to_dialog("Open", admin_dashboard_path, {}, {id: "my-link"})
        expect(link).to have_css("a#my-link")
      end

      context "with title in html options" do
        it "passes html title to sl-tooltip" do
          link = helper.link_to_dialog("Open", admin_dashboard_path, {}, {title: "Open Me"})
          expect(link).to have_css("sl-tooltip[content='Open Me']")
          expect(link).to_not have_css("a[title='Open Me']")
        end
      end

      context "without title in html options" do
        it "has no sl-toolip" do
          link = helper.link_to_dialog("Open", admin_dashboard_path, {}, {})
          expect(link).to_not have_css("sl-tooltip")
          expect(link).to_not have_css("a[title]")
        end
      end
    end

    describe "#link_to_confirm_dialog" do
      subject { link_to_confirm_dialog("Delete", "Sure?", "/delete/me", class: "button") }

      it "renders a link tag with a data attribute for confirm dialog" do
        is_expected.to have_selector(
          "a.button[data-turbo-method='delete'][data-turbo-confirm='Sure?'][href='/delete/me']", text: "Delete"
        )
      end
    end

    describe "#translations_for_select" do
      it "should return an Array of Arrays with available locales" do
        allow(Alchemy::I18n).to receive(:available_locales).and_return(%i[de en cz it])
        expect(helper.translations_for_select.size).to eq(4)
      end
    end

    describe "#clipboard_select_tag_options" do
      let(:page) { build_stubbed(:alchemy_page) }

      before { helper.instance_variable_set(:@page, page) }

      context "with element items" do
        let(:element) { build_stubbed(:alchemy_element) }
        let(:clipboard_items) { [element] }

        it "should include select options with the display name and preview text" do
          allow(element).to receive(:display_name_with_preview_text).and_return(
            "Name with Preview text"
          )
          expect(helper.clipboard_select_tag_options(clipboard_items)).to have_selector(
            "option",
            text: "Name with Preview text"
          )
        end
      end

      context "with page items" do
        let(:page_in_clipboard) { build_stubbed(:alchemy_page, name: "Page name") }
        let(:clipboard_items) { [page_in_clipboard] }

        it "should include select options with page names" do
          expect(helper.clipboard_select_tag_options(clipboard_items)).to have_selector(
            "option",
            text: "Page name"
          )
        end
      end
    end

    describe "#button_with_confirm" do
      subject { button_with_confirm }

      it "renders a button tag with a data attribute for confirm dialog" do
        is_expected.to have_selector("button[data-turbo-confirm]")
      end
    end

    describe "#delete_button" do
      subject { delete_button("/admin/pages") }

      it "renders a button tag" do
        is_expected.to have_selector("button")
      end

      it "returns a form tag with method=delete" do
        is_expected.to have_selector('form input[name="_method"][value="delete"]')
      end

      context "with title in html options" do
        subject(:button) do
          delete_button("/admin/pages", {}, {title: "Open Me"})
        end

        it "passes html title to sl-tooltip" do
          expect(button).to have_css("sl-tooltip[content='Open Me']")
          expect(button).to_not have_css("button[title='Open Me']")
        end
      end

      context "without title in html options" do
        subject(:button) do
          delete_button("/admin/pages", {}, {})
        end

        it "has no sl-toolip" do
          expect(button).to_not have_css("sl-tooltip")
          expect(button).to_not have_css("button[title]")
        end
      end
    end

    describe "#alchemy_datepicker" do
      subject { alchemy_datepicker(ingredient, :value, {value: value, type: type}) }

      let(:ingredient) { Ingredients::Datetime.new }
      let(:value) { nil }
      let(:type) { nil }

      it "renders a text field with data attribute for 'date'" do
        is_expected.to have_selector("alchemy-datepicker[input-type='date'] input[type='text']")
      end

      context "when datetime given as type" do
        let(:type) { :datetime }

        it "renders a text field with data attribute for 'datetime'" do
          is_expected.to have_selector("alchemy-datepicker[input-type='datetime'] input[type='text']")
        end
      end

      context "when time given as type" do
        let(:type) { :time }

        it "renders a text field with data attribute for 'time'" do
          is_expected.to have_selector("alchemy-datepicker[input-type='time'] input[type='text']")
        end
      end

      context "with date given as value" do
        let(:value) { Time.new(2019, 10, 1, 11, 30, 0, "+09:00") }

        it "sets given date as value" do
          is_expected.to have_selector("input[value='2019-10-01T11:30:00+09:00']")
        end
      end

      context "with date stored on object" do
        let(:date) { Time.parse("1976-10-07 00:00 Z") }
        let(:ingredient) { Ingredients::Datetime.new(value: date) }

        it "sets this date as value" do
          is_expected.to have_selector("input[value='1976-10-07T00:00:00Z']")
        end
      end
    end

    describe "#current_alchemy_user_name" do
      subject { helper.current_alchemy_user_name }

      before { expect(helper).to receive(:current_alchemy_user).and_return(user) }

      context "with a user having a `alchemy_display_name` method" do
        let(:user) { double("User", alchemy_display_name: "Peter Schroeder") }

        it "Returns a span showing the name of the currently logged in user." do
          is_expected.to have_content("#{Alchemy.t("Logged in as")} Peter Schroeder")
          is_expected.to have_selector("span.current-user-name")
        end
      end

      context "with a user not having a `alchemy_display_name` method" do
        let(:user) { double("User", name: "Peter Schroeder") }

        it { is_expected.to be_nil }
      end
    end

    describe "#link_url_regexp" do
      subject { helper.link_url_regexp }

      it "returns the regular expression for external link urls" do
        expect(subject).to be_a(Regexp)
      end

      context "if the expression from config is nil" do
        before { stub_alchemy_config(:format_matchers, {link_url: nil}) }

        it "returns the default expression" do
          expect(subject).to_not be_nil
        end
      end
    end

    describe "#hint_with_tooltip" do
      subject { helper.hint_with_tooltip("My hint") }

      it "renders a warning icon with hint text wrapped in tooltip" do
        is_expected.to have_css 'sl-tooltip.like-hint-tooltip[content="My hint"] alchemy-icon[name="alert"]'
      end

      context "with icon set to info" do
        subject { helper.hint_with_tooltip("My hint", icon: "info") }

        it "renders an info icon instead" do
          is_expected.to have_css 'alchemy-icon[name="information"]'
        end
      end
    end
  end
end
