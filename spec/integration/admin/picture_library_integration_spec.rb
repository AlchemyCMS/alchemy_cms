unless ENV["CI"]

  require 'spec_helper'
  require 'support/alchemy/specs_helpers'

  describe "Picture Library", :type => :request do

    before(:all) do
      create_admin_user
      load_authorization_rules
      login_into_alchemy
    end

    describe "Upload" do

      it "should be possible to tag pictures while uploading them" do
        visit '/alchemy/admin/pictures'
        click_on 'Upload image(s)'
        fill_in :tags, :with => 'tag1, tag2'
        attach_file 'Browse', File.expand_path('../../../support/image.png', __FILE__)
        click_on 'upload'
        Alchemy::Picture.find_by_image_filename('image.png').tag_list.should include('tag1')
      end

    end

    describe "Filter by tag" do
      before do
        FactoryGirl.create(:picture, :tag_list => 'bla')
      end
      it "should list all applied tags" do
        visit '/alchemy/admin/pictures'
        page.should have_content 'bla'
      end

      it "should be possible to filter pictures by tag" do
        visit '/alchemy/admin/pictures'
        click_on 'tag1'
        page.should have_content 'bla'
      end
    end
  end

end