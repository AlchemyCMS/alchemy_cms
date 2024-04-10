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

    context "if options[:remote] is given" do
      context "and set to true" do
        subject { helper.alchemy_form_for(resource, remote: true) {} }

        it "makes the form remote" do
          expect(subject).to have_css("form[data-remote]")
        end
      end

      context "and set to false" do
        subject { helper.alchemy_form_for(resource, remote: false) {} }

        it "makes the form non-remote" do
          expect(subject).to have_css("form")
          expect(subject).to_not have_css("form[data-remote]")
        end
      end
    end

    context "if options[:remote] is not given" do
      context "and request is xhr" do
        before do
          allow(helper).to receive(:request).and_return(double(xhr?: true))
        end

        it "makes the form remote" do
          expect(subject).to have_css("form[data-remote]")
        end
      end
    end
  end
end
