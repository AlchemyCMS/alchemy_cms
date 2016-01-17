require 'spec_helper'

module Alchemy
  describe Admin::BaseHelper do
    context "maximum amount of images option" do
      subject { helper.max_image_count }

      before { helper.instance_variable_set('@options', options) }

      context "with max_images option set to emtpy string" do
        let(:options) { {max_images: ""} }

        it { is_expected.to eq(nil) }
      end

      context "with max_images option set to '1'" do
        let(:options) { {max_images: "1"} }

        it { is_expected.to eq(1) }
      end

      context "with maximum_amount_of_images option set to emtpy string" do
        let(:options) { {maximum_amount_of_images: ""} }

        it { is_expected.to eq(nil) }
      end

      context "with maximum_amount_of_images option set to '1'" do
        let(:options) { {maximum_amount_of_images: "1"} }

        it { is_expected.to eq(1) }
      end
    end

    describe "#merge_params" do
      before do
        allow(controller).to receive(:params).and_return({first: '1', second: '2'})
      end

      it "returns a hash that contains the current params and additional params given as attributes" do
        expect(helper.merge_params(third: '3', fourth: '4')).to eq({first: '1', second: '2', third: '3', fourth: '4'})
      end
    end

    describe "#merge_params_without" do
      before do
        allow(controller).to receive(:params).and_return({first: '1', second: '2'})
      end

      it "can delete a single param" do
        expect(helper.merge_params_without(:second)).to eq({first: '1'})
      end

      it "can delete several params" do
        expect(helper.merge_params_without([:first, :second])).to eq({})
      end

      it "can delete a param and add new params at the same time" do
        expect(helper.merge_params_without([:first], {third: '3'})).to eq({second: '2', third: '3'})
      end

      it "should not change params" do
        helper.merge_params_without([:first])
        expect(controller.params).to eq({first: '1', second: '2'})
      end
    end

    describe "#merge_params_only" do
      before do
        allow(controller).to receive(:params).and_return({first: '1', second: '2', third: '3'})
      end

      it "can keep a single param" do
        expect(helper.merge_params_only(:second)).to eq({second: '2'})
      end

      it "can keep several params" do
        expect(helper.merge_params_only([:first, :second])).to eq({first: '1', second: '2'})
      end

      it "can keep a param and add new params at the same time" do
        expect(helper.merge_params_only([:first], {third: '3'})).to eq({first: '1', third: '3'})
      end

      it "should not change params" do
        helper.merge_params_only([:first])
        expect(controller.params).to eq({first: '1', second: '2', third: '3'})
      end
    end

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

      it "renders a date field" do
        is_expected.to have_selector("input[type='date']")
      end

      context "when datetime given as type" do
        let(:type) { :datetime }

        it "renders a datetime field" do
          is_expected.to have_selector("input[type='datetime']")
        end
      end

      context "when time given as type" do
        let(:type) { :time }

        it "renders a time field" do
          is_expected.to have_selector("input[type='time']")
        end
      end

      context "with date given as value" do
        let(:value) { Time.now }

        it "sets given date as value" do
          is_expected.to have_selector("input[value='#{::I18n.l(value, format: :datepicker)}']")
        end
      end

      context 'with date stored on object' do
        let(:date)    { Time.parse('1976-10-07 00:00 Z') }
        let(:essence) { EssenceDate.new(date: date) }

        it "sets this date as value" do
          is_expected.to have_selector("input[value='#{::I18n.l(date, format: :datepicker)}']")
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
          expect(Alchemy::Config).to receive(:get).and_return({link_url: nil})
        end

        it "returns the default expression" do
          expect(subject).to_not be_nil
        end
      end
    end
  end
end
