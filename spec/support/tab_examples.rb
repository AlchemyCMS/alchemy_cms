# frozen_string_literal: true

require "rails_helper"

module Alchemy
  shared_examples_for "a link dialog tab" do |name, title|
    context "default configuration" do
      it "should render a tab with a panel" do
        expect(page).to have_selector("sl-tab[panel='overlay_tab_#{name}_link']")
        expect(page).to have_selector("sl-tab-panel[name='overlay_tab_#{name}_link']")
      end

      it "should have a title" do
        expect(page).to have_text(title)
      end

      it "should allow to add title input" do
        expect(page).to have_selector("input[name=#{name}_link_title]", text: "")
      end

      it "is not active" do
        expect(page).to_not have_selector("sl-tab[active]")
      end
    end

    context "active tab" do
      let(:is_selected) { true }

      it "is active" do
        expect(page).to have_selector("sl-tab[active]")
      end
    end

    context "title input" do
      let(:link_title) { "test" }

      it "should have a pre-filled value" do
        expect(page.find(:css, "input[name=#{name}_link_title]").value).to eq(link_title)
      end
    end
  end

  shared_examples_for "a link dialog - target select" do |name|
    context "target select" do
      context "without content" do
        it "should allow to add target select" do
          expect(page).to have_selector("select[name=#{name}_link_target]")
        end
      end

      context "with content"
      let(:link_target) { "blank" }

      it "should have a pre-filled value" do
        expect(page.find(:css, "select[name=#{name}_link_target]").value).to eq(link_target)
      end
    end
  end
end
