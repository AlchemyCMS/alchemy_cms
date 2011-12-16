require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Alchemy::Picture do

	describe '#suffix' do

		it "should return the suffix of original filename" do
			pic = stub_model(Alchemy::Picture, :image_filename => 'kitten.JPG')
			pic.suffix.should == "jpg"
		end

		context "image has no suffix" do

			before(:each) do
				@pic = stub_model(Alchemy::Picture, :image_filename => 'kitten')
			end

			it "should return empty string" do
				@pic.suffix.should == ""
			end

		end

	end

	describe '#humanized_name' do

		it "should return a humanized version of original filename" do
			pic = stub_model(Alchemy::Picture, :image_filename => 'cute_kitten.JPG')
			pic.humanized_name.should == "Cute kitten"
		end

		it "should not remove incidents of suffix from filename" do
			pic = stub_model(Alchemy::Picture, :image_filename => 'cute_kitten_mo.jpgi.JPG')
			pic.humanized_name.should == "Cute kitten mo.jpgi"
			pic.humanized_name.should_not == "Cute kitten moi"
		end

		context "image has no suffix" do

			before(:each) do
				@pic = stub_model(Alchemy::Picture, :image_filename => 'cute_kitten')
				@pic.stub!(:suffix).and_return("")
			end

			it "should return humanized name" do
				@pic.humanized_name.should == "Cute kitten"
			end

		end

	end

end
