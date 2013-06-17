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
      'controller' => 'admin/events',
      'action' => 'index',
      'sub_navigation' => [{
        'controller' => 'admin/events',
        'action' => 'index'
      }]
    }
  } }

  let(:navigation) { alchemy_module['navigation'] }

  describe '#alchemy_main_navigation_entry' do
    before {
      helper.stub(:url_for_module).and_return('')
      helper.stub(:_t).and_return(alchemy_module['name'])
    }

    context "with permission" do
      before {
        helper.stub(:permitted_to?).and_return(true)
      }

      it "renders the main navigation entry partial" do
        helper.alchemy_main_navigation_entry(alchemy_module).should match /<a.+class="main_navi_entry/
      end
    end

    context "without permission" do
      before {
        helper.stub(:permitted_to?).and_return(false)
      }

      it "returns empty string" do
        helper.alchemy_main_navigation_entry(alchemy_module).should be_empty
      end
    end
  end

  describe '#admin_subnavigation' do
    before {
      helper.stub(:current_alchemy_module).and_return(alchemy_module)
      helper.stub(:url_for_module_sub_navigation).and_return('')
      helper.stub(:_t).and_return(alchemy_module['name'])
    }

    context "with permission" do
      before {
        helper.stub(:permitted_to?).and_return(true)
      }

      it "renders the sub navigation for current module" do
        helper.admin_subnavigation.should match /<div.+class="subnavi_tab/
      end
    end

    context "without permission" do
      before {
        helper.stub(:permitted_to?).and_return(false)
      }

      it "renders the sub navigation for current module" do
        helper.admin_subnavigation.should be_empty
      end
    end

    context "without a module present" do
      before {
        helper.stub(:current_alchemy_module).and_return(nil)
      }

      it "returns nil" do
        helper.admin_subnavigation.should be_nil
      end
    end
  end

  describe '#navigate_module' do
    it "returns array with symbolized controller and action name" do
      helper.navigate_module(navigation).should == [:index, :alchemy_admin_dashboard]
    end
  end

  describe '#main_navigation_css_classes' do
    it "returns string with css classes for main navigation entry" do
      helper.main_navigation_css_classes(navigation).should == "main_navi_entry"
    end

    context "with active entry" do
      before {
        helper.stub(:params).and_return({controller: 'alchemy/admin/dashboard', action: 'index'})
      }

      it "includes active class" do
        helper.main_navigation_css_classes(navigation).should == "main_navi_entry active"
      end
    end
  end

  describe '#entry_active?' do
    let(:entry) {
      {'controller' => 'alchemy/admin/dashboard', 'action' => 'index'}
    }

    context "with active entry" do
      before {
        helper.stub(:params).and_return({controller: 'alchemy/admin/dashboard', action: 'index'})
      }

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
        before {
          entry['action'] = nil
          entry['nested_actions'] = %w(index)
        }

        it "returns true" do
          helper.entry_active?(entry).should be_true
        end
      end
    end

    context "with inactive entry" do
      before {
        helper.stub(:params).and_return({controller: 'alchemy/admin/users', action: 'index'})
      }

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
    context "with module within an engine" do
      let(:navigation) { alchemy_module['navigation']['sub_navigation'].first }

      before {
        helper.stub(:module_definition_for).and_return(alchemy_module)
      }

      it "returns correct url string" do
        helper.url_for_module_sub_navigation(navigation).should == '/admin/layoutpages'
      end
    end

    context "with module within host app" do
      let(:navigation) { event_module['navigation']['sub_navigation'].first }

      before {
        helper.stub(:module_definition_for).and_return(event_module)
      }

      it "returns correct url string" do
        helper.url_for_module_sub_navigation(navigation).should == '/admin/events'
      end
    end
  end

end
