# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::SafeUrlValidator do
  let(:model_class) do
    Class.new do
      include ActiveModel::Validations

      def self.name
        "SafeUrlValidatorDummy"
      end

      attr_accessor :url

      validates_with Alchemy::SafeUrlValidator, attributes: [:url]
    end
  end

  subject(:record) { model_class.new }

  def validate(url)
    record.url = url
    record.valid?
  end

  context "with a blank url" do
    it "is valid" do
      expect(validate(nil)).to be(true)
      expect(validate("")).to be(true)
    end
  end

  context "with an allowed scheme" do
    %w[
      http://example.com
      https://example.com
      mailto:jane@example.com
      tel:+4912345
      ftp://example.com/file.zip
    ].each do |url|
      it "allows #{url}" do
        expect(validate(url)).to be(true)
      end
    end

    it "allows an uppercased scheme" do
      expect(validate("HTTPS://example.com")).to be(true)
    end
  end

  context "with a url that carries no scheme" do
    %w[
      /an/absolute/path
      #an-anchor
      ?query=1
      a/relative/path
      //protocol-relative.example
    ].each do |url|
      it "allows #{url}" do
        expect(validate(url)).to be(true)
      end
    end
  end

  context "with an executable scheme" do
    [
      "javascript:alert(document.domain)",
      "data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==",
      "vbscript:msgbox(1)"
    ].each do |url|
      it "rejects #{url}" do
        expect(validate(url)).to be(false)
      end
    end

    it "adds an error on the attribute" do
      validate("javascript:alert(1)")
      expect(record.errors[:url]).to be_present
    end

    it "rejects a mixed case scheme" do
      expect(validate("JaVaScRiPt:alert(1)")).to be(false)
    end

    it "rejects a scheme hidden behind leading whitespace" do
      expect(validate(" javascript:alert(1)")).to be(false)
    end

    # Browsers strip tabs and newlines from URLs before parsing the scheme, so
    # "java\tscript:" executes. Verified in Firefox.
    it "rejects a scheme split by embedded whitespace" do
      expect(validate("java\tscript:alert(1)")).to be(false)
      expect(validate("java\nscript:alert(1)")).to be(false)
      expect(validate("java\rscript:alert(1)")).to be(false)
    end

    it "rejects a scheme split by an embedded null byte" do
      expect(validate("java" + 0.chr + "script:alert(1)")).to be(false)
    end

    # /^(mailto:|\/|[a-z]+:\/\/)/ style shape matching accepts this, because the
    # "//" reads as an authority while JavaScript reads it as a line comment.
    it "rejects a javascript url disguised as an authority" do
      expect(validate("javascript://%0aalert(1)")).to be(false)
      expect(validate("javascript://\nalert(1)")).to be(false)
    end
  end

  context "when the allowed schemes are configured" do
    around do |example|
      previous = Alchemy.config.allowed_url_schemes.to_a
      Alchemy.config.allowed_url_schemes = %w[https]
      example.run
      Alchemy.config.allowed_url_schemes = previous
    end

    it "allows a configured scheme" do
      expect(validate("https://example.com")).to be(true)
    end

    it "rejects a scheme that is no longer allowed" do
      expect(validate("http://example.com")).to be(false)
    end
  end
end
