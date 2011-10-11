require 'spec_helper'

describe Alchemy::PageLayout do
	
	context "method get_layouts" do
	  it "should generally return page_layouts, nothing else!" do
			Alchemy::PageLayout.get_layouts.should be_instance_of(Array)
	  end

		it "should return the users page_layouts if exists in the application" do
			layouts_file_path = "#{Rails.root}/config/alchemy/page_layouts.yml"
			FileUtils.cp(layouts_file_path, "#{layouts_file_path}.bak")
			File.open(layouts_file_path,'w') do |page_layouts|
				page_layouts.puts "- name: testlayout\n  elements:"
			end
			Alchemy::PageLayout.get_layouts.first.values.should include("testlayout")
			FileUtils.rm(layouts_file_path)
			FileUtils.mv("#{layouts_file_path}.bak", layouts_file_path)
		end
	end

end
