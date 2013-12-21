require 'spec_helper'

module Alchemy
  describe PageLayout do

    describe ".all" do
      # skip memoization
      before { PageLayout.instance_variable_set("@definitions", nil) }

      subject { PageLayout.all }

      it "should return all page_layouts" do
        should be_instance_of(Array)
        subject.collect { |l| l['name'] }.should include('standard')
      end

      context "with empty layouts file" do
        before { YAML.should_receive(:load_file).and_return(false) }

        it "returns empty array" do
          should == []
        end
      end

      context "with missing layouts file" do
        before { File.should_receive(:exists?).and_return(false) }

        it "raises error empty array" do
          expect { subject }.to raise_error(LoadError)
        end
      end
    end

    describe '.add' do
      it "adds a definition to all definitions" do
        PageLayout.add({'name' => 'foo'})
        PageLayout.all.should include({'name' => 'foo'})
      end

      it "adds a array of definitions to all definitions" do
        PageLayout.add([{'name' => 'foo'}, {'name' => 'bar'}])
        PageLayout.all.should include({'name' => 'foo'})
        PageLayout.all.should include({'name' => 'bar'})
      end
    end

    describe ".get" do
      it "should return the page_layout description found by given name" do
        PageLayout.stub(:all).and_return([{'name' => 'default'}, {'name' => 'contact'}])
        expect(PageLayout.get('default')).to eq({'name' => 'default'})
      end
    end

    describe '.layouts_with_own_for_select' do
      it "should not hold a layout twice" do
        layouts = PageLayout.layouts_with_own_for_select('standard', 1, false)
        layouts = layouts.collect(&:last)
        layouts.select { |l| l == "standard" }.length.should == 1
      end
    end

    describe '.selectable_layouts' do
      let(:language) { Language.default }
      before { language }
      subject { PageLayout.selectable_layouts(language.id) }

      it "should not display hidden page layouts" do
        subject.each { |l| l['hide'].should_not == true }
      end

      context "with already taken layouts" do
        before {
          PageLayout.stub(:all).and_return([{'unique' => true}])
          Page.stub_chain(:where, :pluck).and_return([1])
        }

        it "should not include unique layouts" do
          subject.each { |l| l['unique'].should_not == true }
        end
      end

      context "with sites layouts present" do
        let(:site) { Site.new }
        let(:definitions) { [{'name' => 'default_site', 'page_layouts' => %w(intro)}] }
        before { Site.stub(:layout_definitions).and_return(definitions) }

        it "should only return layouts for site" do
          subject.length.should == 1
          subject.first['name'].should == 'intro'
        end
      end
    end

    describe ".element_names_for" do
      it "should return all element names for the given pagelayout" do
        PageLayout.stub(:get).with('default').and_return({'name' => 'default', 'elements' => ['element_1', 'element_2']})
        expect(PageLayout.element_names_for('default')).to eq(['element_1', 'element_2'])
      end

      context "when given page_layout name does not exist" do
        it "should return an empty array" do
          expect(PageLayout.element_names_for('layout_does_not_exist!')).to eq([])
        end
      end

      context "when page_layout description does not contain the elements key" do
        it "should return an empty array" do
          PageLayout.stub(:get).with('layout_without_elements_key').and_return({'name' => 'layout_without_elements_key'})
          expect(PageLayout.element_names_for('layout_without_elements_key')).to eq([])
        end
      end
    end

    describe '.human_layout_name' do
      let(:layout) { {'name' => 'contact'} }
      subject { PageLayout.human_layout_name(layout['name']) }

      context "with no translation present" do
        it "returns the name capitalized" do
          should == 'Contact'
        end
      end

      context "with translation present" do
        before { I18n.should_receive(:t).and_return('Kontakt') }

        it "returns the translated name" do
          should == 'Kontakt'
        end
      end
    end

  end
end
