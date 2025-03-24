# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Resources", type: :system do
  let(:event) { create(:event) }
  let(:second_event) { create(:event, name: "My second Event", entrance_fee: 12.32) }

  before { authorize_user(:as_admin) }

  describe "index view" do
    it "should have a button for creating a new resource items" do
      visit "/admin/events"
      expect(page).to have_selector('#toolbar sl-tooltip a.icon_button alchemy-icon[name="add"]')
    end

    it "should list existing items" do
      event
      second_event
      visit "/admin/events"
      expect(page).to have_content("My Event")
      expect(page).to have_content("something fancy")
      expect(page).to have_content("12.32")
    end

    it "should list existing resource-items nicely formatted" do
      event
      visit "/admin/events"
      expect(page).to have_selector("div#archive_all table.list")
    end

    describe "pagination" do
      before do
        create_list(:event, 15)
      end

      it "should limit the number of items per page based on alchemy's general configuration" do
        stub_alchemy_config(:items_per_page, 5)

        visit "/admin/events"
        expect(page).to have_selector("div#archive_all table.list tbody tr", count: 5)
        expect(page).to have_selector("div#archive_all .pagination .page", count: 3)
      end

      context "params containing per_page" do
        it "should limit the items per page based on the given value" do
          visit "/admin/events?per_page=3"
          expect(page).to have_selector("div#archive_all table.list tbody tr", count: 3)
          expect(page).to have_selector("div#archive_all .pagination .page", count: 5)
        end
      end
    end

    describe "filters" do
      let(:filter_count) { 2 }

      context "resource model has alchemy_resource_filters defined" do
        it "should show selectboxes for the filters" do
          visit "/admin/events"

          within "#library_sidebar #filter_bar" do
            expect(page).to have_selector("select", count: filter_count)
            expect(page).to have_selector("label", text: "By Timeframe")
            expect(page).to have_selector("label", text: "Location")
          end
        end

        context "selecting a filter option" do
          let(:location) { create(:location, name: "berlin") }

          before do
            create(:event, name: "today 1", starts_at: Time.current)
            create(:event, name: "today 2", starts_at: Time.current, location: location)
            create(:event, name: "yesterday", starts_at: Time.current - 1.day)
          end

          it "should filter the list to only show matching items", js: true do
            visit "/admin/events"

            within "div#archive_all table.list tbody" do
              expect(page).to have_selector("tr", count: 3)
              expect(page).to have_content("today 1")
              expect(page).to have_content("today 2")
              expect(page).to have_content("yesterday")
            end

            within "#library_sidebar #filter_bar" do
              select2("Starting today", from: "By Timeframe")
            end

            within "div#archive_all table.list tbody" do
              expect(page).to have_selector("tr", count: 2)
              expect(page).to have_content("today 1")
              expect(page).to have_content("today 2")
              expect(page).to_not have_content("yesterday")
            end

            within "#toolbar" do
              expect(page).to have_link(href: %r{q%5Bby_timeframe%5D=starting_today})
            end
          end

          it "can combine multiple filters" do
            visit "/admin/events?q[by_timeframe]=starting_today&q[by_location_id]=#{location.id}"

            within "div#archive_all table.list tbody" do
              expect(page).to have_selector("tr", count: 1)
              expect(page).to have_content("today 2")
              expect(page).to_not have_content("today 1")
            end
          end

          it "can combine filters and pagination", :js do
            stub_alchemy_config(:items_per_page, 1)

            visit "/admin/events?q[by_timeframe]=starting_today"

            select("4", from: "per_page")

            within "div#archive_all table.list tbody" do
              expect(page).to have_selector("tr", count: 2)
              expect(page).to have_content("today 1")
              expect(page).to have_content("today 2")
              expect(page).not_to have_content("yesterday")
            end
          end

          it "can combine ransack queries and pagination", :js do
            allow_any_instance_of(Admin::EventsController).to receive(:permitted_ransack_search_fields).and_return([:name_start])
            stub_alchemy_config(:items_per_page, 1)

            visit "/admin/events?q[name_start]=today"

            select("4", from: "per_page")

            within "div#archive_all table.list tbody" do
              expect(page).to have_selector("tr", count: 2)
              expect(page).to have_content("today 1")
              expect(page).to have_content("today 2")
              expect(page).not_to have_content("yesterday")
            end
          end

          context "selecting a associated model by it's id" do
            it "should filter the list to only show matching items", :js do
              visit "/admin/events"

              within "div#archive_all table.list tbody" do
                expect(page).to have_selector("tr", count: 3)
              end

              within "#library_sidebar #filter_bar" do
                select2(location.name, from: "Location")
              end

              within "div#archive_all table.list tbody" do
                expect(page).to have_selector("tr", count: 1)
                expect(page).to have_content("today 2")
              end
            end
          end
        end
      end

      context "with no tagged items" do
        before do
          create(:event, tag_list: nil)
        end

        it "should not show the tag list" do
          visit "/admin/events"

          within "#library_sidebar" do
            expect(page).to_not have_selector(".tag-list")
          end
        end
      end

      context "with tagged items" do
        before do
          create_list(:event, 2, tag_list: ["remote"])
          create(:event, name: "onsite event", tag_list: ["onsite"])
        end

        it "should list all tags including the number of tagged items" do
          visit "/admin/events"

          within "#library_sidebar" do
            expect(page).to have_selector(".tag-list a", text: "remote (2)")
            expect(page).to have_selector(".tag-list a", text: "onsite (1)")
          end
        end

        context "selecting a tag from the list" do
          it "should filter the list to only show matching items" do
            visit "/admin/events"

            within "div#archive_all table.list tbody" do
              expect(page).to have_selector("tr", count: 3)
            end

            find("#library_sidebar .tag-list a", text: "onsite (1)").click

            within "div#archive_all table.list tbody" do
              expect(page).to have_selector("tr", count: 1)
              expect(page).to have_selector("td", text: "onsite event")
            end
          end
        end
      end
    end

    describe "date fields" do
      let(:yesterday) { Date.yesterday }
      let(:tomorrow) { Date.tomorrow }

      before do
        Booking.create(from: yesterday, until: tomorrow)
      end

      it "displays date values" do
        Alchemy::Deprecation.silence do
          visit "/admin/bookings"
        end
        expect(page).to have_content(yesterday)
        expect(page).to have_content(tomorrow)
      end
    end
  end

  describe "form for creating and updating items" do
    it "renders an input field according to the attribute's type" do
      visit "/admin/events/new"
      expect(page).to have_selector('input#event_name[type="text"]')
      expect(page).to have_selector('alchemy-datepicker[input-type="datetime"] input#event_starts_at')
      expect(page).to have_selector('alchemy-datepicker[input-type="datetime"] input#event_ends_at')
      expect(page).to have_selector("textarea#event_description")
      expect(page).to have_selector('input#event_published[type="checkbox"]')
      expect(page).to have_selector('alchemy-datepicker[input-type="time"] input#event_lunch_starts_at')
      expect(page).to have_selector('alchemy-datepicker[input-type="time"] input#event_lunch_ends_at')
    end

    it "should have a select box for associated models" do
      visit "/admin/events/new"
      within("form") do
        expect(page).to have_selector("select#event_location_id")
      end
    end

    it "should have a select box for enums values" do
      visit "/admin/events/new"

      within("form") do
        expect(page).to have_selector("select#event_event_type")
      end
    end

    describe "date fields" do
      it "have date picker" do
        visit "/admin/bookings/new"
        expect(page).to have_selector('alchemy-datepicker[input-type="date"] input#booking_from')
      end
    end
  end

  describe "create resource item" do
    context "when form filled with valid data" do
      let!(:location) { create(:location) }
      let(:start_date) { 1.week.from_now }

      before do
        visit "/admin/events/new"
        fill_in "event_name", with: "My second event"
        fill_in "event_starts_at", with: start_date
        select location.name, from: "Location"
        click_on "Save"
      end

      it "lists the new item" do
        expect(page).to have_content "My second event"
        expect(page).to have_content I18n.l(start_date, format: :"alchemy.default")
      end

      it "shows a success message" do
        expect(page).to have_content("Event successfully created.")
      end
    end

    context "when form filled with invalid data" do
      before do
        visit "/admin/events/new"
        fill_in "event_name", with: "" # invalid!
        click_on "Save"
      end

      it "shows the form again" do
        expect(page).to have_selector "form input#event_name"
      end

      it "lists invalid fields" do
        expect(page).to have_content("can't be blank")
      end

      it "should not display success notice" do
        expect(page).not_to have_content("Event successfully created.")
      end
    end
  end

  describe "updating an item" do
    before do
      visit("/admin/events/#{event.id}/edit")
      fill_in "event_name", with: "New event name"
      click_on "Save"
    end

    it "shows the updated value" do
      expect(page).to have_content("New event name")
    end

    it "shows a success message" do
      expect(page).to have_content("Event successfully updated.")
    end
  end

  describe "destroying an item" do
    before do
      event
      second_event
      visit "/admin/events"
      within("tr", text: "My second Event") do
        click_button_with_tooltip "Delete"
      end
    end

    it "shouldn't be on the list anymore" do
      expect(page).to have_content "My Event"
      expect(page).not_to have_content "My second Event"
    end

    it "should display success message" do
      expect(page).to have_content("Event successfully removed.")
    end
  end

  context "with event that acts_as_taggable" do
    it "shows an autocomplete tag list in the form" do
      visit "/admin/events/new"
      expect(page).to have_selector('alchemy-tags-autocomplete input#event_tag_list[type="text"]')
    end

    context "with tagged events in the index view" do
      let!(:event) { create(:event, name: "Casablanca", tag_list: "Matinee") }
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
        expect(page).to have_link(nil, href: "/admin/events/#{event.id}/edit?tagged_with=Matinee")
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
        expect(page).to have_content("Starting Today")
        expect(page).to have_content("Future")
      end

      # Here we visit the pages manually, as we don't want to test the JS here.
      visit "/admin/events?q[by_timeframe]=starting_today"
      expect(page).to have_content("Car Expo")
      expect(page).to_not have_content("Hovercar Expo")
      expect(page).to_not have_content("Horse Expo")

      visit "/admin/events?q[by_timeframe]=future"
      expect(page).to have_content("Hovercar Expo")
      expect(page).to_not have_content("Car Expo")
      expect(page).to_not have_content("Horse Expo")

      # Keep the filter when editing an event
      expect(page).to have_link(nil, href: "/admin/events/#{future_event.id}/edit?q%5Bby_timeframe%5D=future")
    end

    it "does not work with undefined scopes" do
      visit "/admin/events?q[by_timeframe]=undefined_scope"
      expect(page).to have_content("Car Expo")
      expect(page).to have_content("Hovercar Expo")
      expect(page).to have_content("Horse Expo")
    end

    context "full text search" do
      it "should respect filters" do
        visit "/admin/events?q[by_timeframe]=future"

        expect(page).to have_content("Hovercar Expo")
        expect(page).to_not have_content("Car Expo")
        expect(page).to_not have_content("Horse Expo")

        page.find(".search_input_field").set("Horse")
        page.find(".search_field button").click

        expect(page).to_not have_content("Hovercar Expo")
        expect(page).to_not have_content("Car Expo")
        expect(page).to_not have_content("Horse Expo")
      end
    end
  end
end
