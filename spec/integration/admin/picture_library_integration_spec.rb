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
        fill_in :tag_list, :with => 'tag1, tag2'
        attach_file 'Browse', File.expand_path('../../../support/image.png', __FILE__)
        click_on 'upload'
        Alchemy::Picture.find_by_image_filename('image.png').tag_list.should include('tag1')
      end

    end

    describe "Tagging" do

      it "is possible to edit tags after clicking on the picture", :js => true do
        picture = FactoryGirl.create(:picture, :tag_list => 'tag1')
        visit '/alchemy/admin/pictures'
save_and_open_page
        within("#picture_#{picture.id}") do
          click_link 'show_in_window'
        end
save_and_open_page

        # Doesn't work, so:
        #visit "/alchemy/admin/pictures/#{picture.id}/show_in_window"

        fill_in :tag_list, :with => 'tag3, tag4'
        click_on 'Update Picture'
        page.should have_content 'tag3'
      end

      it "is possible to filter tags by clicking on its name in the tag list" do
        picture = FactoryGirl.create(:picture, :tag_list => 'tag1', :name => 'TaggedWith1')
        picture = FactoryGirl.create(:picture, :tag_list => 'tag2', :name => 'TaggedWith2')
        visit '/alchemy/admin/pictures'
        click_on 'tag1'
        page.should have_content 'TaggedWith1'
        page.should_not have_content 'TaggedWith2'
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