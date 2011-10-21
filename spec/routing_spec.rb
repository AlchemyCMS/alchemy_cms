require 'spec_helper'

describe "The Routing", :type => :routing do

	it "should have routes for legacy washapp downloads" do
		{
			:get => "/wa_files/download/11"
		}.should route_to(
	    :controller => "attachments",
	    :action => "download",
	    :id => "11"
	  )
	end

	it "should have routes for legacy webmate downloads" do
	  {
			:get => "/uploads/files/0000/0028/Pressetext.pdf"
		}.should route_to(
    	:controller => "attachments",
    	:action => "download",
    	:id => "0028",
			:name => "Pressetext",
			:suffix => "pdf"
		)
	end

end
