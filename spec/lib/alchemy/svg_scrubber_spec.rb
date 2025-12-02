require "rails_helper"
require "alchemy/svg_scrubber"

RSpec.describe Alchemy::SvgScrubber do
  subject(:scrubber) { described_class.new }

  describe "#scrub" do
    def scrub(svg)
      Loofah.xml_fragment(svg).scrub!(scrubber).to_s
    end

    it "removes script elements" do
      expect(scrub("<svg><script>alert(1)</script></svg>")).not_to include("<script>")
    end

    it "removes foreignObject elements" do
      expect(scrub("<svg><foreignObject></foreignObject></svg>")).not_to include("<foreignObject")
    end

    it "removes event handlers" do
      result = scrub('<svg onload="alert(1)"><rect onclick="alert(2)"/></svg>')
      expect(result).not_to include("onload")
      expect(result).not_to include("onclick")
    end

    it "keeps safe elements" do
      result = scrub("<svg><rect/><circle/><text>Hello</text></svg>")
      expect(result).to include("<rect")
      expect(result).to include("<circle")
      expect(result).to include("<text>")
    end

    it "removes animations targeting href" do
      result = scrub('<svg><set attributeName="href" to="javascript:alert(1)"/></svg>')
      expect(result).not_to include("<set")
    end

    it "keeps safe animations" do
      result = scrub('<svg><animate attributeName="opacity" from="0" to="1"/></svg>')
      expect(result).to include("<animate")
    end

    it "removes javascript: URLs from href" do
      result = scrub('<svg><a href="javascript:alert(1)">Link</a></svg>')
      expect(result).not_to include("javascript:")
      expect(result).to include("<a")
    end

    it "removes dangerous style attributes" do
      result = scrub('<svg><rect style="background:url(javascript:alert(1))"/></svg>')
      expect(result).not_to include("style=")
    end
  end

  describe "safe_url?" do
    it "allows safe image data URIs" do
      %w[
        data:image/png;base64,abc123
        data:image/jpeg;base64,abc123
        data:image/gif;base64,abc123
        data:image/webp;base64,abc123
      ].each do |uri|
        expect(scrubber.send(:safe_url?, uri)).to be(true), "Expected #{uri} to be safe"
      end
    end

    it "blocks dangerous data URIs" do
      %w[
        data:text/html,<script>alert(1)</script>
        data:image/svg+xml;base64,abc123
      ].each do |uri|
        expect(scrubber.send(:safe_url?, uri)).to be(false), "Expected #{uri} to be blocked"
      end
    end

    it "blocks javascript and vbscript URLs" do
      %w[
        javascript:alert(1)
        vbscript:msgbox(1)
      ].each do |uri|
        expect(scrubber.send(:safe_url?, uri)).to be(false), "Expected #{uri} to be blocked"
      end
    end

    it "allows http, https, and local references" do
      %w[
        http://example.com/image.png
        https://example.com/image.png
        #local-id
        /path/to/resource
      ].each do |uri|
        expect(scrubber.send(:safe_url?, uri)).to be(true), "Expected #{uri} to be safe"
      end
    end
  end
end
