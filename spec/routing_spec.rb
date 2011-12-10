require 'spec_helper'

describe "The Routing", :type => :routing do

	before(:each) { @routes = Alchemy::Engine.routes }

	context "for downloads" do

		it "should have a named route" do
			{
				:get => "/attachment/32/download/Presseveranstaltung.pdf"
			}.should route_to(
				:controller => "alchemy/attachments",
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
				:controller => "alchemy/attachments",
				:action => "download",
				:id => "32"
			)
		end

		it "should have a route for legacy washAPP downloads" do
			{
				:get => "/wa_files/download/11"
			}.should route_to(
				:controller => "alchemy/attachments",
				:action => "download",
				:id => "11"
			)
		end

		it "should have a route for legacy WebMate downloads" do
			{
				:get => "/uploads/files/0000/0028/Pressetext.pdf"
			}.should route_to(
				:controller => "alchemy/attachments",
				:action => "download",
				:id => "0028",
				:name => "Pressetext",
				:suffix => "pdf"
			)
		end

	end

	describe "nested url" do

		context "one level deep nested" do

			it "should route to pages show" do
				{
					:get => "/products/my-product"
				}.should route_to(
					:controller => "alchemy/pages",
					:action => "show",
					:level1 => "products",
					:urlname => "my-product"
				)
			end

			context "and language" do

				it "should route to pages show" do
					{
						:get => "/de/products/my-product"
					}.should route_to(
						:controller => "alchemy/pages",
						:action => "show",
						:level1 => "products",
						:urlname => "my-product",
						:lang => "de"
					)
				end

			end

		end

		context "two levels deep nested" do

			it "should route to pages show" do
				{
					:get => "/catalog/products/my-product"
				}.should route_to(
					:controller => "alchemy/pages",
					:action => "show",
					:level1 => "catalog",
					:level2 => "products",
					:urlname => "my-product"
				)
			end

			context "and language" do

				it "should route to pages show" do
					{
						:get => "/de/catalog/products/my-product"
					}.should route_to(
						:controller => "alchemy/pages",
						:action => "show",
						:level1 => "catalog",
						:level2 => "products",
						:urlname => "my-product",
						:lang => "de"
					)
				end

			end

		end

		context "with a blog date url" do

			it "should route to pages show" do
				{
					:get => "/2011/12/08/my-post"
				}.should route_to(
					:controller => "alchemy/pages",
					:action => "show",
					:level1 => "2011",
					:level2 => "12",
					:level3 => "08",
					:urlname => "my-post"
				)
			end

			context "and language" do

				it "should route to pages show" do
					{
						:get => "/de/2011/12/08/my-post"
					}.should route_to(
						:controller => "alchemy/pages",
						:action => "show",
						:level1 => "2011",
						:level2 => "12",
						:level3 => "08",
						:urlname => "my-post",
						:lang => "de"
					)
				end

			end

		end

	end

end
