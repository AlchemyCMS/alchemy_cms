require 'spec_helper'

describe "Resources" do
  let(:event)        { FactoryGirl.create(:event) }
  let(:second_event) { FactoryGirl.create(:event, :name => 'My second Event', :entrance_fee => 12.32) }

  before { authorize_user(:as_admin) }

  describe "index view" do

    it "should have a button for creating a new resource items" do
      visit '/admin/events'
      expect(page).to have_selector('#toolbar div.button_with_label a.icon_button span.icon.create')
    end

    it "should list existing items" do
      event
      second_event
      visit '/admin/events'
      expect(page).to have_content("My Event")
      expect(page).to have_content("something fancy")
      expect(page).to have_content("12.32")
    end

    it "should list existing resource-items nicely formatted" do
      event
      visit '/admin/events'
      expect(page).to have_selector('div#archive_all table.list')
    end

  end

  describe "form for creating and updating items" do
    it "renders an input field according to the attribute's type" do
      visit '/admin/events/new'
      expect(page).to have_selector('input#event_name[type="text"]')
      expect(page).to have_selector('input#event_starts_at[type="date"]')
      expect(page).to have_selector('textarea#event_description')
      expect(page).to have_selector('input#event_published[type="checkbox"]')
      expect(page).to have_selector('input#event_lunch_starts_at_1i[type="hidden"]')
      expect(page).to have_selector('input#event_lunch_starts_at_2i[type="hidden"]')
      expect(page).to have_selector('input#event_lunch_starts_at_3i[type="hidden"]')
      expect(page).to have_selector('select#event_lunch_starts_at_4i')
      expect(page).to have_selector('select#event_lunch_starts_at_5i')
    end

    it "should have a select box for associated models" do
      visit '/admin/events/new'
      within('form') do
        expect(page).to have_selector('select')
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
        expect(page).to have_content "My second event"
        expect(page).to have_content "03 Mar 2012"
      end

      it "shows a success message" do
        expect(page).to have_content("Succesfully created")
      end
    end

    context "when form filled with invalid data" do
      before do
        visit '/admin/events/new'
        fill_in 'event_name', :with => '' #invalid!
        click_on 'Save'
      end

      it "shows the form again" do
        expect(page).to have_selector "form input#event_name"
      end

      it "lists invalid fields" do
        expect(page).to have_content("can't be blank")
      end

      it "should not display success notice" do
        expect(page).not_to have_content("successfully created")
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
      expect(page).to have_content("New event name")
    end

    it "shows a success message" do
      expect(page).to have_content("Succesfully updated")
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
      expect(page).to have_content "My Event"
      expect(page).not_to have_content "My second Event"
    end

    it "should display success message" do
      expect(page).to have_content("Succesfully removed")
    end
  end

end
