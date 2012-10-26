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

  end
end
