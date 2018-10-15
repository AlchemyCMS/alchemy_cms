# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Admin::BaseHelper do
    describe '#toolbar_button' do
      context "with permission" do
        before { allow(helper).to receive(:can?).and_return(true) }

        it "renders a toolbar button" do
          expect(helper.toolbar_button(
                   url: admin_dashboard_path
          )).to match /<div.+class="button_with_label/
        end
      end

      context "without permission" do
        before { allow(helper).to receive(:can?).and_return(false) }

        it "returns empty string" do
          expect(
            helper.toolbar_button(url: admin_dashboard_path)
          ).to be_empty
        end
      end

      context "with disabled permission check" do
        before { allow(helper).to receive(:can?).and_return(false) }

        it "returns the button" do
          expect(
            helper.toolbar_button(
              url: admin_dashboard_path,
              skip_permission_check: true
            )
          ).to match /<div.+class="button_with_label/
        end
      end

      context "with empty permission option" do
        before { allow(helper).to receive(:can?).and_return(true) }

        it "returns reads the permission from url" do
          expect(helper).to receive(:permission_array_from_url)
          expect(
            helper.toolbar_button(
              url: admin_dashboard_path,
              if_permitted_to: ''
            )
          ).not_to be_empty
        end
      end

      context "with overlay option set to false" do
        before do
          allow(helper).to receive(:can?).and_return(true)
          expect(helper).to receive(:permission_array_from_url)
        end

        it "renders a normal link" do
          button = helper.toolbar_button(
            url: admin_dashboard_path,
            overlay: false
          )
          expect(button).to match /<a.+href="#{admin_dashboard_path}"/
          expect(button).not_to match /data-alchemy-overlay/
        end
      end
    end

    describe "#translations_for_select" do
      it "should return an Array of Arrays with available locales" do
        allow(Alchemy::I18n).to receive(:available_locales).and_return([:de, :en, :cz, :it])
        expect(helper.translations_for_select.size).to eq(4)
      end
    end

    describe '#clipboard_select_tag_options' do
      let(:page) { build_stubbed(:alchemy_page) }

      before { helper.instance_variable_set('@page', page) }

      context 'with element items' do
        let(:element) { build_stubbed(:alchemy_element) }
        let(:clipboard_items) { [element] }

        it "should include select options with the display name and preview text" do
          allow(element).to receive(:display_name_with_preview_text).and_return('Name with Preview text')
          expect(helper.clipboard_select_tag_options(clipboard_items)).to have_selector('option', text: 'Name with Preview text')
        end

        context "when @page can have cells" do
          before { allow(page).to receive(:can_have_cells?).and_return(true) }

          it "should group the elements in the clipboard by cell" do
            expect(helper).to receive(:grouped_elements_for_select).and_return({})
            helper.clipboard_select_tag_options(clipboard_items)
          end
        end
      end

      context 'with page items' do
        let(:page_in_clipboard) { build_stubbed(:alchemy_page, name: 'Page name') }
        let(:clipboard_items) { [page_in_clipboard] }

        it "should include select options with page names" do
          expect(helper.clipboard_select_tag_options(clipboard_items)).to have_selector('option', text: 'Page name')
        end
      end
    end

    describe '#button_with_confirm' do
      subject { button_with_confirm }

      it "renders a button tag with a data attribute for confirm dialog" do
        is_expected.to have_selector('button[data-alchemy-confirm]')
      end
    end

    describe '#delete_button' do
      subject { delete_button('/admin/pages') }

      it "renders a button tag" do
        is_expected.to have_selector('button')
      end

      it "returns a form tag with method=delete" do
        is_expected.to have_selector('form input[name="_method"][value="delete"]')
      end
    end

    describe '#alchemy_datepicker' do
      subject { alchemy_datepicker(essence, :date, {value: value, type: type}) }

      let(:essence) { EssenceDate.new }
      let(:value) { nil }
      let(:type) { nil }

      it "renders a text field with data attribute for 'date'" do
        is_expected.to have_selector("input[type='text'][data-datepicker-type='date']")
      end

      context "when datetime given as type" do
        let(:type) { :datetime }

        it "renders a text field with data attribute for 'datetime'" do
          is_expected.to have_selector("input[type='text'][data-datepicker-type='datetime']")
        end
      end

      context "when time given as type" do
        let(:type) { :time }

        it "renders a text field with data attribute for 'time'" do
          is_expected.to have_selector("input[type='text'][data-datepicker-type='time']")
        end
      end

      context "with date given as value" do
        let(:value) { Time.now }

        it "sets given date as value" do
          is_expected.to have_selector("input[value='#{::I18n.l(value, format: :'alchemy.datepicker')}']")
        end
      end

      context 'with date stored on object' do
        let(:date)    { Time.parse('1976-10-07 00:00 Z') }
        let(:essence) { EssenceDate.new(date: date) }

        it "sets this date as value" do
          is_expected.to have_selector("input[value='#{::I18n.l(date, format: :'alchemy.datepicker')}']")
        end
      end
    end

    describe '#current_alchemy_user_name' do
      subject { helper.current_alchemy_user_name }

      before { expect(helper).to receive(:current_alchemy_user).and_return(user) }

      context 'with a user having a `alchemy_display_name` method' do
        let(:user) { double('User', alchemy_display_name: 'Peter Schroeder') }

        it "Returns a span showing the name of the currently logged in user." do
          is_expected.to have_content("#{Alchemy.t('Logged in as')} Peter Schroeder")
          is_expected.to have_selector("span.current-user-name")
        end
      end

      context 'with a user not having a `alchemy_display_name` method' do
        let(:user) { double('User', name: 'Peter Schroeder') }

        it { is_expected.to be_nil }
      end
    end

    describe '#link_url_regexp' do
      subject { helper.link_url_regexp }

      it "returns the regular expression for external link urls" do
        expect(subject).to be_a(Regexp)
      end

      context 'if the expression from config is nil' do
        before do
          stub_alchemy_config(:format_matchers, {link_url: nil})
        end

        it "returns the default expression" do
          expect(subject).to_not be_nil
        end
      end
    end

    describe '#hint_with_tooltip' do
      subject { helper.hint_with_tooltip('My hint') }

      it 'renders a warning icon with hint text wrapped in tooltip', :aggregate_failures do
        is_expected.to have_css 'span.hint-with-icon i.fa-exclamation-triangle'
        is_expected.to have_css 'span.hint-with-icon span.hint-bubble'
        is_expected.to have_content 'My hint'
      end

      context 'with icon set to info' do
        subject { helper.hint_with_tooltip('My hint', icon: 'info') }

        it 'renders an info icon instead' do
          is_expected.to have_css 'i.fa-info'
        end
      end
    end
  end
end
