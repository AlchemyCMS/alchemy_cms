require 'spec_helper'

describe "The Routing", :type => :routing do

	context "for downloads" do
	
		it "should have a named route" do
			pending "Because Rspec does not support namespaced engines yet!"
		  {
				:get => "/alchemy/attachment/32/download/Presseveranstaltung.pdf"
			}.should route_to(
	    	:controller => "alchemy/attachments",
	    	:action => "download",
	    	:id => "32",
				:name => "Presseveranstaltung",
				:suffix => "pdf"
			)
		end
		
		it "should have a route for legacy Alchemy 1.x downloads" do
			pending "Because Rspec does not support namespaced engines yet!"
		  {
				:get => "/alchemy/attachment/32/download?name=Presseveranstaltung.pdf"
			}.should route_to(
	    	:controller => "alchemy/attachments",
	    	:action => "download",
	    	:id => "32"
			)
		end
		
	  it "should have a route for legacy washAPP downloads" do
			pending "Because Rspec does not support namespaced engines yet!"
			{
				:get => "/alchemy/wa_files/download/11"
			}.should route_to(
		    :controller => "alchemy/attachments",
		    :action => "download",
		    :id => "11"
		  )
		end

		it "should have a route for legacy WebMate downloads" do
			pending "Because Rspec does not support namespaced engines yet!"
		  {
				:get => "/alchemy/uploads/files/0000/0028/Pressetext.pdf"
			}.should route_to(
	    	:controller => "alchemy/attachments",
	    	:action => "download",
	    	:id => "0028",
				:name => "Pressetext",
				:suffix => "pdf"
			)
		end
		
	end

end
