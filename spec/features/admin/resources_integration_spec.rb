require 'spec_helper'

describe "Resources" do
  let(:event)        { FactoryGirl.create(:event) }
  let(:second_event) { FactoryGirl.create(:event, :name => 'My second Event', :entrance_fee => 12.32) }

  before { authorize_as_admin }

  describe "index view" do

    it "should have a button for creating a new resource items" do
      visit '/admin/events'
      page.should have_selector('#toolbar div.button_with_label a.icon_button span.icon.create')
    end

    it "should list existing items" do
      event
      second_event
      visit '/admin/events'
      page.should have_content("My Event")
      page.should have_content("something fancy")
      page.should have_content("12.32")
    end

    it "should list existing resource-items nicely formatted" do
      event
      visit '/admin/events'
      page.should have_selector('div#archive_all table.list')
    end

  end

  describe "form for creating and updating items" do
    it "renders an input field according to the attribute's type" do
      visit '/admin/events/new'
      page.should have_selector('input#event_name[type="text"]')
      page.should have_selector('input#event_starts_at[type="date"]')
      page.should have_selector('textarea#event_description')
      page.should have_selector('input#event_published[type="checkbox"]')
    end

    it "should have a select box for associated models" do
      visit '/admin/events/new'
      within('form') do
        page.should have_selector('select')
      end
    end
  end

  describe "create resource item" do

    context "when form filled with valid data" do
      before do
        visit '/admin/events/new'
        fill_in 'event_name', :with => 'My second event'
        fill_in 'event_starts_at', :with => DateTime.new(2012, 03, 03, 20, 00)
        click_on 'Save'
      end

      it "lists the new item" do
        page.should have_content "My second event"
        page.should have_content "03 Mar 2012"
      end

      it "shows a success message" do
        page.should have_content("Succesfully created")
      end
    end

    context "when form filled with invalid data" do
      before do
        visit '/admin/events/new'
        fill_in 'event_name', :with => '' #invalid!
        click_on 'Save'
      end

      it "shows the form again" do
        page.should have_selector "form input#event_name"
      end

      it "lists invalid fields" do
        page.should have_content("can't be blank")
      end

      it "should not display success notice" do
        page.should_not have_content("successfully created")
      end
    end

  end

  describe "updating an item" do
    before do
      visit("/admin/events/#{event.id}/edit")
      fill_in 'event_name', :with => 'New event name'
      click_on 'Save'
    end

    it "shows the updated value" do
      page.should have_content("New event name")
    end

    it "shows a success message" do
      page.should have_content("Succesfully updated")
    end
  end

  describe "destroying an item" do
    before do
      event
      second_event
      visit '/admin/events'
      within('tr', :text => 'My second Event') do
        click_on 'Delete'
      end
    end

    it "shouldn't be on the list anymore" do
      page.should have_content "My Event"
      page.should_not have_content "My second Event"
    end

    it "should display success message" do
      page.should have_content("Succesfully removed")
    end
  end

end
