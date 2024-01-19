# frozen_string_literal: true

require "rails_helper"
require "alchemy/scrubbers/safe_list"

RSpec.describe Alchemy::Scrubbers::SafeList do
  let(:config) { {} }
  let(:scrubber) { described_class.new(config) }
  subject { Loofah.html5_fragment(html).scrub!(scrubber).to_html }

  describe "#scrub" do
    context "with a tag that is not allowed" do
      let(:html) { "<script> console.log('oops') </script>" }

      it { is_expected.to eq("") }
    end

    context "with an allowed tag" do
      let(:html) { "<p>Some text</p>" }

      it { is_expected.to eq(html) }
    end

    context "with an allowed attribute" do
      let(:html) { "<p class=\"pretty\">Some text</p>" }

      it { is_expected.to eq(html) }
    end

    context "with a disallowed attribute" do
      let(:html) { "<p style='color: red;'>Some text</p>" }

      it { is_expected.to eq("<p>Some text</p>") }
    end

    context "with a link with a space in the href" do
      let(:html) { "<a href=\"/hello/ \">Hello!</a>" }

      it { is_expected.to eq(html) }
    end
  end
end
