require 'spec_helper'

module Alchemy
  describe PageLayout do

    context "method get_layouts" do

      it "should generally return page_layouts, nothing else!" do
        PageLayout.read_layouts_file.should be_instance_of(Array)
      end

    end

    context "with custom page layouts" do

      it "should return the users page_layouts if exists in the application" do
        @config_path = Rails.root.join("config/alchemy")
        FileUtils.mv(File.join(@config_path, 'page_layouts.yml'), File.join(@config_path, 'page_layouts.bak'))
        layouts_file = File.join(@config_path, 'page_layouts.yml')
        File.open(layouts_file, 'w') do |page_layouts|
          page_layouts.puts "- name: testlayout\n  elements:"
        end
        PageLayout.read_layouts_file.first.values.should include("testlayout")
      end

      after(:each) do
        FileUtils.mv(File.join(@config_path, 'page_layouts.bak'), File.join(@config_path, 'page_layouts.yml'))
      end

    end

    it "should not display hidden page layouts" do
      PageLayout.selectable_layouts(Language.get_default).each { |e| e["hide"].should_not == true }
    end

  end
end
