# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Forms::Builder, type: :controller do
  let(:object_name) { "Ding" }
  let(:form_object) { double("FormObject", foo: "Baz") }

  let(:template) do
    double(
      "Template",
      controller: controller,
      label: "<label>",
      text_field: "<input>",
      content_tag: "<div>",
    )
  end

  let(:builder) { described_class.new(object_name, form_object, template, {}) }

  describe "#datepicker" do
    let(:attribute) { :foo }

    subject { builder.datepicker(attribute, options) }

    context "with date value" do
      context "on the object" do
        let(:options) { { as: :date } }
        let(:form_object) { double("FormObject", foo: "2021-07-14") }

        it "returns input field with date value set" do
          expect(template).to receive(:text_field).with("Ding", :foo, hash_including(
            type: :text,
            data: { datepicker_type: :date },
            value: "2021-07-14T00:00:00Z",
            class: [:string, :required, :date],
          ))
          subject
        end
      end

      context "in the html options" do
        let(:options) { { as: :date, input_html: { value: "2021-08-01" } } }

        it "returns input field with parsed date value set" do
          expect(template).to receive(:text_field).with("Ding", :foo, hash_including(
            type: :text,
            data: { datepicker_type: :date },
            value: "2021-08-01T00:00:00Z",
            class: [:string, :required, :date],
          ))
          subject
        end
      end
    end

    context "as date" do
      let(:options) { { as: :date } }

      it "returns input field with datepicker attributes" do
        expect(template).to receive(:text_field).with("Ding", :foo, hash_including(
          type: :text,
          data: { datepicker_type: :date },
          value: nil,
          class: [:string, :required, :date],
        ))
        subject
      end
    end

    context "as time" do
      let(:options) { { as: :time } }

      it "returns input field with datepicker attributes" do
        expect(template).to receive(:text_field).with("Ding", :foo, hash_including(
          type: :text,
          data: { datepicker_type: :time },
          value: nil,
          class: [:string, :required, :time],
        ))
        subject
      end
    end

    context "as datetime" do
      let(:options) { { as: :datetime } }

      it "returns input field with datepicker attributes" do
        expect(template).to receive(:text_field).with("Ding", :foo, hash_including(
          type: :text,
          data: { datepicker_type: :datetime },
          value: nil,
          class: [:string, :required, :datetime],
        ))
        subject
      end
    end
  end
end
