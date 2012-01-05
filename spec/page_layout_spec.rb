require 'spec_helper'

describe Alchemy::PageLayout do
	
	context "method get_layouts" do

	  it "should generally return page_layouts, nothing else!" do
			Alchemy::PageLayout.read_layouts_file.should be_instance_of(Array)
	  end

	end

	context "with custom page layouts" do

		it "should return the users page_layouts if exists in the application" do
			@config_path = Rails.root.join("config/alchemy")
			FileUtils.mkdir_p(@config_path)
			layouts_file = File.join(@config_path, 'page_layouts.yml')
			File.open(layouts_file,'w') do |page_layouts|
				page_layouts.puts "- name: testlayout\n  elements:"
			end
			Alchemy::PageLayout.read_layouts_file.first.values.should include("testlayout")
		end

		after(:each) do
			FileUtils.rm_rf(@config_path)
		end

	end

end
