require 'spec_helper'

describe 'Picture renderung security', :js => true do

  let(:picture) { Alchemy::Picture.create(:image_file => File.new(File.expand_path('../../fixtures/image.png', __FILE__))) }

  # Prevent the signup view from being rendered.
  before { Alchemy.user_class.stub(:count).and_return 1 }

  context "passing no security token" do

    it 'should return a bad request (400)' do
      visit "/pictures/#{picture.id}/show/image.png"
      page.status_code.should == 400
    end

  end

  context "passing correct security token" do

    before do
      visit "/pictures/#{picture.id}/show/image.png?sh=#{picture.security_token}"
    end

    it 'should return image' do
      page.body.should match(/img/)
    end

    it 'should return status ok (200)' do
      page.status_code.should == 200
    end

  end

end
