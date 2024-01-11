# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Forms::Builder, type: :controller do
  let(:object_name) { "Ding" }
  let(:form_object) { double("FormObject", foo: "Baz") }

  shared_examples_for "datepicker expect" do
    it "has the alchemy-datepicker" do
      expect(template).to receive(:content_tag).with("alchemy-datepicker", "<alchemy-datepicker>", {type: type})
      subject
    end

    it "returns input field" do
      expect(template).to receive(:text_field).with(
        "Ding",
        :foo,
        hash_including(
          type: :text,
          value: value,
          class: [:string, :required, type]
        )
      )
      subject
    end
  end

  let(:builder) { described_class.new(object_name, form_object, template, {}) }

  describe "#datepicker" do
    let(:attribute) { :foo }

    let(:template) do
      double(
        "Template",
        controller: controller,
        label: "<label>",
        text_field: "<input>",
        content_tag: "<alchemy-datepicker>"
      )
    end

    subject { builder.datepicker(attribute, options) }

    context "with date value" do
      context "on the object" do
        let(:options) { {as: :date} }
        let(:form_object) { double("FormObject", foo: "2021-07-14") }

        it_behaves_like "datepicker expect" do
          let(:type) { :date }
          let(:value) { "2021-07-14T00:00:00Z" }
        end
      end

      context "in the html options" do
        let(:options) { {as: :date, input_html: {value: "2021-08-01"}} }

        it_behaves_like "datepicker expect" do
          let(:type) { :date }
          let(:value) { "2021-08-01T00:00:00Z" }
        end
      end
    end

    context "as date" do
      let(:options) { {as: :date} }

      it_behaves_like "datepicker expect" do
        let(:type) { :date }
        let(:value) { nil }
      end
    end

    context "as time" do
      let(:options) { {as: :time} }

      it_behaves_like "datepicker expect" do
        let(:type) { :time }
        let(:value) { nil }
      end
    end

    context "as datetime" do
      let(:options) { {as: :datetime} }

      it_behaves_like "datepicker expect" do
        let(:type) { :datetime }
        let(:value) { nil }
      end
    end
  end

  describe "#richtext" do
    let(:attribute) { :foo }

    let(:template) do
      double(
        "Template",
        controller: controller,
        label: "<label>",
        text_area: "<textarea>",
        content_tag: "<alchemy-tinymce>"
      )
    end

    subject { builder.richtext(attribute) }

    it "uses a alchemy-tinymce" do
      expect(template).to receive(:text_area).with(
        "Ding",
        :foo,
        hash_including(
          class: [:text, :required]
        )
      )
      expect(template).to receive(:content_tag).with("alchemy-tinymce", "<alchemy-tinymce>")
      subject
    end
  end
end
