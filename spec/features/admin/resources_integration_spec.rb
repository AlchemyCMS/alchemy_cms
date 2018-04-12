# frozen_string_literal: true

require 'spec_helper'

describe "Resources" do
  let(:event)        { create(:event) }
  let(:second_event) { create(:event, name: 'My second Event', entrance_fee: 12.32) }

  before { authorize_user(:as_admin) }

  describe "index view" do
    it "should have a button for creating a new resource items" do
      visit '/admin/events'
      expect(page).to have_selector('#toolbar div.button_with_label a.icon_button .icon.fa-plus')
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
      expect(page).to have_selector('input#event_starts_at[data-datepicker-type="datetime"]')
      expect(page).to have_selector('input#event_ends_at[data-datepicker-type="datetime"]')
      expect(page).to have_selector('textarea#event_description')
      expect(page).to have_selector('input#event_published[type="checkbox"]')
      expect(page).to have_selector('input#event_lunch_starts_at[data-datepicker-type="time"]')
      expect(page).to have_selector('input#event_lunch_ends_at[data-datepicker-type="time"]')
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
      let!(:location) { create(:location) }

      before do
        visit '/admin/events/new'
        fill_in 'event_name', with: 'My second event'
        fill_in 'event_starts_at', with: Time.local(2012, 03, 03, 20, 00)
        select location.name, from: 'Location'
        click_on 'Save'
      end

      it "lists the new item" do
        expect(page).to have_content "My second event"
        expect(page).to have_content "03 Mar 2012"
      end

      it "shows a success message" do
        expect(page).to have_content("Successfully created")
      end
    end

    context "when form filled with invalid data" do
      before do
        visit '/admin/events/new'
        fill_in 'event_name', with: '' # invalid!
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
      fill_in 'event_name', with: 'New event name'
      click_on 'Save'
    end

    it "shows the updated value" do
      expect(page).to have_content("New event name")
    end

    it "shows a success message" do
      expect(page).to have_content("Successfully updated")
    end
  end

  describe "destroying an item" do
    before do
      event
      second_event
      visit '/admin/events'
      within('tr', text: 'My second Event') do
        click_on 'Delete'
      end
    end

    it "shouldn't be on the list anymore" do
      expect(page).to have_content "My Event"
      expect(page).not_to have_content "My second Event"
    end

    it "should display success message" do
      expect(page).to have_content("Successfully removed")
    end
  end

  context "with event that acts_as_taggable" do
    it "shows an autocomplete tag list in the form" do
      visit "/admin/events/new"
      expect(page).to have_selector('input#event_tag_list[type="text"][data-autocomplete="/admin/tags/autocomplete"]')
    end

    context "with tagged events in the index view" do
      let!(:event)        { create(:event, name: "Casablanca", tag_list: "Matinee") }
      let!(:second_event) { create(:event, name: "Die Hard IX", tag_list: "Late Show") }

      before { visit "/admin/events" }

      it "shows the tag filter sidebar" do
        within "#library_sidebar" do
          expect(page).to have_content("Matinee")
          expect(page).to have_content("Late Show")
        end
      end

      it "filters the events when clicking a tag", aggregate_failures: true do
        click_link "Matinee"
        expect(page).to have_content("Casablanca")
        expect(page).to_not have_content("Die Hard IX")

        # Keep the tags when editing an event
        click_link "Edit"
        click_button "Save"
        expect(page).to have_content("Casablanca")
        expect(page).to_not have_content("Die Hard IX")
      end
    end
  end

  context "with event that has filters defined" do
    let!(:past_event) { create(:event, name: "Horse Expo", starts_at: Time.current - 100.years) }
    let!(:today_event) { create(:event, name: "Car Expo", starts_at: Time.current.at_noon) }
    let!(:future_event) { create(:event, name: "Hovercar Expo", starts_at: Time.current + 30.years) }

    it "lets the user filter by the defined scopes", aggregate_failures: true do
      visit "/admin/events"
      within "#library_sidebar" do
        expect(page).to have_content("Starting today")
        expect(page).to have_content("Future")
      end

      # Here we visit the pages manually, as we don't want to test the JS here.
      visit "/admin/events?filter=starting_today"
      expect(page).to     have_content("Car Expo")
      expect(page).to_not have_content("Hovercar Expo")
      expect(page).to_not have_content("Horse Expo")

      visit "/admin/events?filter=future"
      expect(page).to     have_content("Hovercar Expo")
      expect(page).to_not have_content("Car Expo")
      expect(page).to_not have_content("Horse Expo")

      # Keep the filter when editing an event
      click_link "Edit"
      click_button "Save"
      expect(page).to     have_content("Hovercar Expo")
      expect(page).to_not have_content("Car Expo")
      expect(page).to_not have_content("Horse Expo")
    end

    it "does not work with undefined scopes" do
      visit "/admin/events?filter=undefined_scope"
      expect(page).to have_content("Car Expo")
      expect(page).to have_content("Hovercar Expo")
      expect(page).to have_content("Horse Expo")
    end
  end
end
