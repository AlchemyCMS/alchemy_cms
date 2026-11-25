require "rails_helper"

RSpec.describe Alchemy::Admin::FormHelper do
  describe "#alchemy_form_for" do
    subject { helper.alchemy_form_for(resource) {} }

    let(:resource) do
      [alchemy, :admin, Alchemy::Element.new(name: "article")]
    end

    it "returns a form with alchemy class" do
      expect(subject).to have_css(".alchemy")
    end

    it "enables browser validations" do
      expect(subject).not_to have_css("form[novalidate]")
    end

    context "with errors" do
      let(:page) { Alchemy::Page.new }
      let(:resource) { [alchemy, :admin, page] }

      before do
        page.errors.add(:name, :blank)
        page.errors.add(:permitted_roles, :blank)
        page.errors.add(:base, "Something went wrong")
      end

      context "on attributes without an input" do
        subject { helper.alchemy_form_for(resource) { |f| f.input(:name) } }

        it "lists them above the form fields" do
          expect(subject).to have_css("form > alchemy-message[type='error'][icon='warn'] + .input")
          expect(subject).to have_css("alchemy-message[type='error']", text: page.errors.full_messages_for(:permitted_roles).first)
          expect(subject).to have_css("alchemy-message[type='error']", text: "Something went wrong")
        end

        it "does not repeat errors already shown at their input" do
          expect(subject).to have_css(".input small.error", text: "can't be blank")
          expect(subject).to_not have_css("alchemy-message", text: "Name can't be blank")
        end
      end

      context "on an attribute rendered as hidden field" do
        subject { helper.alchemy_form_for(resource) { |f| f.hidden_field(:permitted_roles) } }

        it "lists them" do
          expect(subject).to have_css("alchemy-message[type='error']", text: page.errors.full_messages_for(:permitted_roles).first)
        end
      end

      context "on nested records" do
        subject do
          helper.alchemy_form_for(resource) do |f|
            f.fields_for(:draft_version, page.draft_version) { |v| v.input(:public_on) }
          end
        end

        before do
          page.errors.clear
          page.errors.import(
            page.draft_version.errors.add(:public_on, :blank),
            attribute: "draft_version.public_on"
          )
          page.errors.import(
            page.draft_version.errors.add(:public_until, :blank),
            attribute: "draft_version.public_until"
          )
        end

        it "only lists errors no nested input shows" do
          expect(subject).to have_css("alchemy-message[type='error']", text: "Draft version public until can't be blank")
          expect(subject).to_not have_css("alchemy-message", text: "public on")
        end
      end

      context "if the error summary is disabled" do
        subject { helper.alchemy_form_for(resource, error_summary: false) {} }

        it "does not list them" do
          expect(subject).to_not have_css("alchemy-message")
        end
      end
    end

    context "without errors" do
      let(:resource) { [alchemy, :admin, Alchemy::Page.new] }

      it "renders no error message" do
        expect(subject).to_not have_css("alchemy-message")
      end
    end
  end
end
