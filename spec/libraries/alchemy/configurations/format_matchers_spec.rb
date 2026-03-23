# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configurations::FormatMatchers do
  subject(:format_matchers) { described_class.new }

  describe "#email" do
    it "matches valid emails" do
      expect("user@example.com").to match(format_matchers.email)
    end

    it "does not match invalid emails" do
      expect("not-an-email").not_to match(format_matchers.email)
      expect("user@").not_to match(format_matchers.email)
      expect("@example.com").not_to match(format_matchers.email)
    end
  end

  describe "#url" do
    it "matches valid URLs" do
      expect("example.com").to match(format_matchers.url)
      expect("sub.example.com").to match(format_matchers.url)
      expect("example.com:8080").to match(format_matchers.url)
      expect("example.com/path").to match(format_matchers.url)
    end

    it "does not match invalid URLs" do
      expect("not a url").not_to match(format_matchers.url)
    end
  end

  describe "#link_url" do
    it "matches tel: links" do
      expect("tel:+1234567890").to match(format_matchers.link_url)
    end

    it "matches mailto: links" do
      expect("mailto:user@example.com").to match(format_matchers.link_url)
    end

    it "matches absolute paths" do
      expect("/some/path").to match(format_matchers.link_url)
    end

    it "matches protocol URLs" do
      expect("https://example.com").to match(format_matchers.link_url)
      expect("http://example.com").to match(format_matchers.link_url)
    end

    it "does not match relative paths" do
      expect("relative/path").not_to match(format_matchers.link_url)
    end
  end
end
