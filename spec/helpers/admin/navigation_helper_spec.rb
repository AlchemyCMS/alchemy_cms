require 'spec_helper'

describe Alchemy::Admin::NavigationHelper do
  let(:alchemy_module) { {
    'name' => 'dashboard',
    'engine_name' => 'alchemy',
    'navigation' => {
      'name' => 'modules.dashboard',
      'controller' => 'alchemy/admin/dashboard',
      'action' => 'index',
      'icon' => 'dashboard',
      'sub_navigation' => [{
        'controller' => 'alchemy/admin/layoutpages',
        'action' => 'index'
      }]
    }
  } }

  let(:event_module) { {
    'navigation' => {
      'controller' => '/admin/events',
      'action' => 'index',
      'sub_navigation' => [{
        'controller' => '/admin/events',
        'action' => 'index'
      }]
    }
  } }

  let(:navigation) { alchemy_module['navigation'] }

  describe '#alchemy_main_navigation_entry' do
    before do
      helper.stub(:url_for_module).and_return('')
      helper.stub(:_t).and_return(alchemy_module['name'])
    end

    context "with permission" do
      before do
        helper.stub(:can?).and_return(true)
      end

      it "renders the main navigation entry partial" do
        helper.alchemy_main_navigation_entry(alchemy_module).should match /<a.+class="main_navi_entry/
      end
    end

    context "without permission" do
      before do
        helper.stub(:can?).and_return(false)
      end

      it "returns empty string" do
        helper.alchemy_main_navigation_entry(alchemy_module).should be_empty
      end
    end
  end

  describe '#admin_subnavigation' do
    before do
      helper.stub(:current_alchemy_module).and_return(alchemy_module)
      helper.stub(:url_for_module_sub_navigation).and_return('')
      helper.stub(:_t).and_return(alchemy_module['name'])
    end

    context "with permission" do
      before do
        helper.stub(:can?).and_return(true)
      end

      it "renders the sub navigation for current module" do
        helper.admin_subnavigation.should match /<div.+class="subnavi_tab/
      end
    end

    context "without permission" do
      before do
        helper.stub(:can?).and_return(false)
      end

      it "renders the sub navigation for current module" do
        helper.admin_subnavigation.should be_empty
      end
    end

    context "without a module present" do
      before do
        helper.stub(:current_alchemy_module).and_return(nil)
      end

      it "returns nil" do
        helper.admin_subnavigation.should be_nil
      end
    end
  end

  describe '#navigate_module' do
    it "returns array with symbolized action and controller name" do
      helper.navigate_module(navigation).should == [:index, :alchemy_admin_dashboard]
    end

    it "stringifies keys" do
      helper.navigate_module({action: 'index', controller: 'alchemy/admin/pictures'}).should == [:index, :alchemy_admin_pictures]
    end

    it "removes leading slash" do
      helper.navigate_module({action: 'index', controller: '/admin/pictures'}).should == [:index, :admin_pictures]
    end
  end

  describe '#main_navigation_css_classes' do
    it "returns string with css classes for main navigation entry" do
      helper.main_navigation_css_classes(navigation).should == "main_navi_entry"
    end

    context "with active entry" do
      before do
        helper.stub(:params).and_return({controller: 'alchemy/admin/dashboard', action: 'index'})
      end

      it "includes active class" do
        helper.main_navigation_css_classes(navigation).should == "main_navi_entry active"
      end
    end
  end

  describe '#entry_active?' do
    let(:entry) do
      {'controller' => 'alchemy/admin/dashboard', 'action' => 'index'}
    end

    context "with active entry" do
      before do
        helper.stub(:params).and_return({controller: 'alchemy/admin/dashboard', action: 'index'})
      end

      it "returns true" do
        helper.entry_active?(entry).should be_true
      end

      context "and with leading slash in controller name" do
        before { entry['controller'] = '/alchemy/admin/dashboard' }

        it "returns true" do
          helper.entry_active?(entry).should be_true
        end
      end

      context "but with action listed in nested_actions key" do
        before do
          entry['action'] = nil
          entry['nested_actions'] = %w(index)
        end

        it "returns true" do
          helper.entry_active?(entry).should be_true
        end
      end
    end

    context "with inactive entry" do
      before do
        helper.stub(:params).and_return({controller: 'alchemy/admin/users', action: 'index'})
      end

      it "returns false" do
        helper.entry_active?(entry).should be_false
      end
    end
  end

  describe '#url_for_module' do
    context "with module within an engine" do
      it "returns correct url string" do
        helper.url_for_module(alchemy_module).should == '/admin/dashboard'
      end
    end

    context "with module within host app" do
      it "returns correct url string" do
        helper.url_for_module(event_module).should == '/admin/events'
      end
    end
  end

  describe '#url_for_module_sub_navigation' do
    subject { helper.url_for_module_sub_navigation(navigation) }

    let(:current_module) { alchemy_module }
    let(:navigation)     { current_module['navigation']['sub_navigation'].first }

    before do
      helper.stub(module_definition_for: current_module)
    end

    context "with module within an engine" do
      let(:current_module) { alchemy_module }

      it "returns correct url string" do
        should == '/admin/layoutpages'
      end
    end

    context "with module within host app" do
      let(:current_module) { event_module }

      it "returns correct url string" do
        should == '/admin/events'
      end
    end

    context 'without module found' do
      before do
        helper.stub(module_definition_for: nil)
      end

      it { should be_nil }
    end
  end

  describe "#sorted_alchemy_modules" do
    subject { helper.sorted_alchemy_modules }

    context 'with position attribute on modules' do
      before do
        alchemy_module['position'] = 1
        event_module['position'] = 2
        helper.stub(alchemy_modules: [event_module, alchemy_module])
      end

      it "returns sorted alchemy modules" do
        should eq([alchemy_module, event_module])
      end
    end

    context 'with no position attribute on one module' do
      before do
        event_module['position'] = 2
        helper.stub(alchemy_modules: [alchemy_module, event_module])
      end

      it "appends this module at the end" do
        should eq([event_module, alchemy_module])
      end
    end
  end

end
