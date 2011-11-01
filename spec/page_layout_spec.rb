require 'spec_helper'

describe Alchemy::PageLayout do
	
	context "method get_layouts" do
	  it "should generally return page_layouts, nothing else!" do
			Alchemy::PageLayout.get_layouts.should be_instance_of(Array)
	  end

		it "should return the users page_layouts if exists in the application" do
			config_path = FileUtils.mkdir_p("#{Rails.root}/config/alchemy")
			layouts_file = File.join(config_path, 'page_layouts.yml')
			File.open(layouts_file,'w') do |page_layouts|
				page_layouts.puts "- name: testlayout\n  elements:"
			end
			Alchemy::PageLayout.get_layouts.first.values.should include("testlayout")
			FileUtils.rm_rf(config_path)
		end
	end

end
