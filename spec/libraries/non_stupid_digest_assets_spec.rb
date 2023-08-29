# frozen_string_literal: true

require "spec_helper"
require "non_stupid_digest_assets"

RSpec.describe NonStupidDigestAssets do
  describe ".assets" do
    context "when the whitelist is empty" do
      it "returns the assets" do
        NonStupidDigestAssets.whitelist = []
        assets = {"foo.js" => "foo-123.js"}
        expect(NonStupidDigestAssets.assets(assets)).to eq(assets)
      end
    end

    context "when the whitelist is not empty" do
      it "returns the assets that match the whitelist of regex" do
        NonStupidDigestAssets.whitelist = [/foo/]
        assets = {"foo.js" => "foo-123.js", "bar.js" => "bar-123.js"}
        expect(NonStupidDigestAssets.assets(assets)).to eq("foo.js" => "foo-123.js")
      end

      it "returns the assets that match the whitelist of strings" do
        NonStupidDigestAssets.whitelist = ["foo.js"]
        assets = {"foo.js" => "foo-123.js", "bar.js" => "bar-123.js"}
        expect(NonStupidDigestAssets.assets(assets)).to eq("foo.js" => "foo-123.js")
      end
    end
  end
end
