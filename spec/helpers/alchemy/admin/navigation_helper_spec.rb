# frozen_string_literal: true

require 'spec_helper'

describe Alchemy::Admin::NavigationHelper do
  let(:alchemy_module) do
    {
      'name' => 'dashboard',
      'engine_name' => 'alchemy',
      'navigation' => {
        'name' => 'modules.dashboard',
        'controller' => 'alchemy/admin/dashboard',
        'action' => 'index',
        'icon' => 'dashboard'
      }
    }
  end

  let(:module_with_subnavigation) do
    {
      'name' => 'library',
      'engine_name' => 'alchemy',
      'navigation' => {
        'name' => 'modules.library',
        'controller' => 'alchemy/admin/pictures',
        'action' => 'index',
        'sub_navigation' => [{
          'name' => 'modules.pictures',
          'controller' => 'alchemy/admin/pictures',
          'action' => 'index'
        }, {
          'name' => 'modules.files',
          'controller' => 'alchemy/admin/attachments',
          'action' => 'index'
        }]
      }
    }
  end

  let(:event_module) do
    {
      'navigation' => {
        'controller' => '/admin/events',
        'action' => 'index',
        'sub_navigation' => [{
          'controller' => '/admin/events',
          'action' => 'index'
        }]
      }
    }
  end

  let(:event_module_with_params) do
    {
      'navigation' => {
        'controller' => '/admin/events',
        'action' => 'index',
        'params' => {
          'key' => 'value'
        },
        'sub_navigation' => [{
          'controller' => '/admin/events',
          'action' => 'index',
          'params' => {
            'key' => 'value',
            'key2' => 'value2'
          }
       }]
      }
    }
  end

  let(:navigation) { alchemy_module['navigation'] }

  describe '#alchemy_main_navigation_entry' do
    before do
      allow(helper).to receive(:url_for_module).and_return('')
      allow(Alchemy).to receive(:t).and_return(alchemy_module['name'])
    end

    context "with permission" do
      before do
        allow(helper).to receive(:can?).and_return(true)
      end

      it "renders the main navigation entry partial" do
        expect(helper.alchemy_main_navigation_entry(alchemy_module)).
          to have_selector '.main_navi_entry'
      end

      context "when module has sub navigation" do
        let(:alchemy_module) do
          module_with_subnavigation
        end

        before do
          allow(helper).to receive(:module_definition_for) do
            alchemy_module
          end
        end

        it 'includes the sub navigation' do
          expect(helper.alchemy_main_navigation_entry(alchemy_module)).
            to have_selector '.main_navi_entry .sub_navigation'
        end
      end
    end

    context "without permission" do
      before do
        allow(helper).to receive(:can?).and_return(false)
      end

      it "returns empty string" do
        expect(helper.alchemy_main_navigation_entry(alchemy_module)).to be_empty
      end
    end
  end

  describe '#navigate_module' do
    it "returns array with symbolized action and controller name" do
      expect(helper.navigate_module(navigation)).to eq([:index, :alchemy_admin_dashboard])
    end

    context "when controller name has a leading slash" do
      let(:navigation) do
        {
          'action' => 'index',
          'controller' => '/admin/pictures'
        }
      end

      it "removes leading slash" do
        expect(helper.navigate_module(navigation)).to eq([:index, :admin_pictures])
      end
    end
  end

  describe '#main_navigation_css_classes' do
    it "returns string with css classes for main navigation entry" do
      expect(helper.main_navigation_css_classes(navigation)).to eq(%w(main_navi_entry))
    end

    context "with active entry" do
      before do
        allow(helper).to receive(:params).and_return({
          controller: 'alchemy/admin/dashboard',
          action: 'index'
        })
      end

      it "includes active class" do
        expect(helper.main_navigation_css_classes(navigation)).to eq(%w(main_navi_entry active))
      end
    end
  end

  describe '#entry_active?' do
    let(:entry) do
      {'controller' => 'alchemy/admin/dashboard', 'action' => 'index'}
    end

    context "with active entry" do
      before do
        allow(helper).to receive(:params) do
          {
            controller: 'alchemy/admin/dashboard',
            action: 'index'
          }
        end
      end

      it "returns true" do
        expect(helper.entry_active?(entry)).to be_truthy
      end

      context "and with leading slash in controller name" do
        before { entry['controller'] = '/alchemy/admin/dashboard' }

        it "returns true" do
          expect(helper.entry_active?(entry)).to be_truthy
        end
      end

      context "but with action listed in nested_actions key" do
        before do
          entry['action'] = nil
          entry['nested_actions'] = %w(index)
        end

        it "returns true" do
          expect(helper.entry_active?(entry)).to be_truthy
        end
      end
    end

    context "with inactive entry" do
      before do
        expect(helper).to receive(:params) do
          {
            controller: 'alchemy/admin/users',
            action: 'index'
          }
        end
      end

      it "returns false" do
        expect(helper.entry_active?(entry)).to be_falsey
      end
    end
  end

  describe '#url_for_module' do
    context "with module within an engine" do
      it "returns correct url string" do
        expect(helper.url_for_module(alchemy_module)).to eq('/admin/dashboard')
      end
    end

    context "with module within host app" do
      it "returns correct url string" do
        expect(helper.url_for_module(event_module)).to eq('/admin/events')
      end

      it "returns correct url string with params" do
        expect(helper.url_for_module(event_module_with_params)).to eq('/admin/events?key=value')
      end
    end
  end

  describe '#url_for_module_sub_navigation' do
    let(:current_module) do
      module_with_subnavigation
    end

    let(:navigation) do
      current_module['navigation']['sub_navigation'].first
    end

    subject { helper.url_for_module_sub_navigation(navigation) }

    context 'with module found' do
      before do
        expect(helper).to receive(:module_definition_for).and_return current_module
      end

      context "with module within an engine" do
        it "returns correct url string" do
          is_expected.to eq('/admin/pictures')
        end
      end

      context "with module within host app" do
        let(:current_module) { event_module }

        it "returns correct url string" do
          is_expected.to eq('/admin/events')
        end
      end

      context "with module within host app with params" do
        let(:current_module) { event_module_with_params }

        it "returns correct url string with params" do
          is_expected.to eq('/admin/events?key2=value2&key=value')
        end
      end
    end

    context 'without module found' do
      before do
        expect(helper).to receive(:module_definition_for).and_return nil
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#sorted_alchemy_modules" do
    subject { helper.sorted_alchemy_modules }

    context 'with position attribute on modules' do
      before do
        alchemy_module['position'] = 1
        event_module['position'] = 2
        expect(helper).to receive(:alchemy_modules).and_return [event_module, alchemy_module]
      end

      it "returns sorted alchemy modules" do
        is_expected.to eq([alchemy_module, event_module])
      end
    end

    context 'with no position attribute on one module' do
      before do
        event_module['position'] = 2
        expect(helper).to receive(:alchemy_modules).and_return [alchemy_module, event_module]
      end

      it "appends this module at the end" do
        is_expected.to eq([event_module, alchemy_module])
      end
    end
  end
end
