# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples_for "having file name sanitization" do
  describe "file name sanitization" do
    context "with file name given" do
      let(:invalid_file_name) { 'some/../path"<script>alert(1)</script>.png' }
      let(:sanitized_file_name) { "script&gt;.png" }

      it "sanitizes the file name before saving" do
        subject.send("#{file_name_attribute}=", invalid_file_name)
        subject.save
        expect(subject.send(file_name_attribute)).to eq(sanitized_file_name)
      end
    end
    context "with file name being nil" do
      let(:file_name) { nil }

      it "does not sanitizes the file name before saving" do
        subject.send("#{file_name_attribute}=", file_name)
        subject.save
        expect(subject.send(file_name_attribute)).to be_nil
      end
    end
  end
end
