# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::TagsList, type: :component do
  let(:component) do
    described_class.new(class_name)
  end

  subject(:render) do
    render_inline component
  end

  context "with nil given as class_name parameter" do
    let(:class_name) { nil }

    it "raises argument error" do
      expect { component }.to raise_error(ArgumentError)
    end
  end

  context "with class_name given" do
    let(:class_name) { "Alchemy::Attachment" }

    let(:params) do
      ActionController::Parameters.new
    end

    before do
      allow(component).to receive(:search_filter_params) do
        params.permit!.merge(controller: "admin/attachments", action: "index", use_route: "alchemy")
      end
    end

    context "with tagged objects" do
      let(:tag) { mock_model(Gutentag::Tag, name: "foo", count: 1) }
      let(:tag2) { mock_model(Gutentag::Tag, name: "abc", count: 1) }

      before do
        expect(Alchemy::Attachment).to receive(:tag_counts).and_return([tag, tag2])
        render
      end

      it "returns a tag list as <li> tags" do
        expect(page).to have_selector("li")
      end

      it "has the tags name in the li's name attribute" do
        expect(page).to have_selector("li[name='#{tag.name}']")
      end

      it "tags are sorted alphabetically" do
        expect(page).to have_selector("li[name='#{tag2.name}'] + li[name='#{tag.name}']")
      end

      context "with lowercase and uppercase tag names mixed" do
        let(:tag) { mock_model(Gutentag::Tag, name: "Foo", count: 1) }

        it "tags are sorted alphabetically correctly" do
          expect(page).to have_selector("li[name='#{tag2.name}'] + li[name='#{tag.name}']")
        end
      end

      context "when filter and search params are present" do
        let(:params) do
          ActionController::Parameters.new(
            filter: "foo",
            q: {name_eq: "foo"}
          )
        end

        it "keeps them" do
          expect(page).to have_selector('a[href*="filter"]')
          expect(page).to have_selector('a[href*="name_eq"]')
        end
      end

      context "if the filter list params contains the given tag" do
        let(:params) do
          ActionController::Parameters.new(tagged_with: "foo,bar,baz")
        end

        it "has active class on tag" do
          expect(page).to have_selector('li[name="foo"].active')
        end
      end

      context "if the filter list params does not contain the given tag" do
        let(:params) do
          ActionController::Parameters.new(tagged_with: "bar,baz")
        end

        it "has no active class" do
          expect(page).to_not have_selector("li.active")
        end
      end

      context "params[:tagged_with] is not present" do
        let(:params) do
          ActionController::Parameters.new
        end

        it "has no active class" do
          expect(page).to_not have_selector("li.active")
        end
      end
    end

    context "without any tagged objects" do
      it "returns empty string" do
        expect(rendered_content).to be_nil
      end
    end
  end
end
