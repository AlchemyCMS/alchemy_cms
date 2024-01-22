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

      it "removes the tag" do
        is_expected.to eq("")
      end
    end

    context "with an iframe" do
      let(:html) { "<iframe> myframe </iframe>" }

      it "removes the tag" do
        is_expected.to eq("")
      end
    end

    context "with an allowed tag" do
      let(:html) { "<p>Some text</p>" }

      it "does not remove the tag" do
        is_expected.to eq(html)
      end
    end

    context "with an allowed attribute" do
      let(:html) { "<p class=\"pretty\">Some text</p>" }

      it "does not remove the attribute" do
        is_expected.to eq(html)
      end
    end

    context "with a disallowed attribute" do
      let(:html) { "<p style='color: red;'>Some text</p>" }

      it "removes the attribute" do
        is_expected.to eq("<p>Some text</p>")
      end
    end

    context "with a link with a space in the href" do
      let(:html) { "<a href=\"/hello/ \">Hello!</a>" }

      it "does not escape the trailing whitespace" do
        is_expected.to eq(html)
      end
    end

    context "with a node nested in a disallowed node" do
      let(:config) { {safe_tags: ["a"]} }
      let(:html) { "<h1><a href=\"/hello/ \">Hello!</a></h1>" }

      it "keeps the nested node" do
        is_expected.to eq("<a href=\"/hello/ \">Hello!</a>")
      end
    end
  end
end
