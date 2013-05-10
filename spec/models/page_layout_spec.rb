require 'spec_helper'

module Alchemy
  describe PageLayout do

    describe ".all" do

      it "should return all page_layouts" do
        layouts = PageLayout.all
        layouts.should be_instance_of(Array)
        layouts.collect { |l| l['name'] }.should include('standard')
      end

    end

    describe '.layouts_with_own_for_select' do

      it "should not hold a layout twice" do
        layouts = PageLayout.layouts_with_own_for_select('standard', 1, false)
        layouts = layouts.collect(&:last)
        layouts.select { |l| l == "standard" }.length.should == 1
      end

    end

    it "should not display hidden page layouts" do
      PageLayout.selectable_layouts(Language.get_default).each { |e| e["hide"].should_not == true }
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

  end
end
