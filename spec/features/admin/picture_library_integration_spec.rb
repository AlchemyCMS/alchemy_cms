require 'spec_helper'

describe "Picture Library", js: true do

  before do
    authorize_as_admin
  end

  describe "Tagging" do

    before do
      picture = FactoryGirl.create(:picture, tag_list: 'tag1', name: 'TaggedWith1')
      picture = FactoryGirl.create(:picture, tag_list: 'tag2', name: 'TaggedWith2')
    end

    it "it should be possible to filter tags by clicking on its name in the tag list" do
      visit '/admin/pictures'
      click_on 'tag1 (1)'
      page.should have_content 'TaggedWith1'
      page.should_not have_content 'TaggedWith2'
    end

    it "it should be possible to undo tag filtering by clicking on an active tag name" do
      visit '/admin/pictures'
      click_on 'tag1 (1)'
      page.should_not have_content 'TaggedWith2'
      click_on 'tag1 (1)'
      page.should have_content 'TaggedWith2'
    end

    it "it should be possible to tighten the tag scope by clicking on another tag name" do
      visit '/admin/pictures'
      click_on 'tag1 (1)'
      click_on 'tag2 (1)'
      page.should have_content "You don't have any images in your archive"
    end

  end

  describe "Filter by tag" do

    before do
      FactoryGirl.create(:picture, tag_list: 'bla')
    end

    it "should list all applied tags" do
      visit '/admin/pictures'
      page.should have_content 'bla'
    end

    it "should be possible to filter pictures by tag" do
      visit '/admin/pictures'
      click_on 'bla (1)'
      page.should have_content 'bla'
    end

  end
end
