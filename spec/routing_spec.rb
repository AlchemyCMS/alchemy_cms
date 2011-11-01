require 'spec_helper'

describe "The Routing", :type => :routing do

	context "for downloads" do
	
		it "should have a named route" do
		  {
				:get => "/attachment/32/download/Presseveranstaltung.pdf"
			}.should route_to(
	    	:controller => "attachments",
	    	:action => "download",
	    	:id => "32",
				:name => "Presseveranstaltung",
				:suffix => "pdf"
			)
		end
		
		it "should have a route for legacy Alchemy 1.x downloads" do
		  {
				:get => "/attachment/32/download?name=Presseveranstaltung.pdf"
			}.should route_to(
	    	:controller => "attachments",
	    	:action => "download",
	    	:id => "32"
			)
		end
		
	  it "should have a route for legacy washAPP downloads" do
			{
				:get => "/wa_files/download/11"
			}.should route_to(
		    :controller => "attachments",
		    :action => "download",
		    :id => "11"
		  )
		end

		it "should have a route for legacy WebMate downloads" do
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

end
