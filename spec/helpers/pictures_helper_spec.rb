require "spec_helper"

describe Alchemy::PicturesHelper do

	describe "alchemy_picture_path" do

		it "should route to show_picture_path" do
			pic = mock_model("Picture", :urlname => 'cute-kitten', :id => 1)
			helper.alchemy_picture_path(pic).should == '/alchemy/pictures/1/show/cute-kitten.jpg'
		end

	end

end
