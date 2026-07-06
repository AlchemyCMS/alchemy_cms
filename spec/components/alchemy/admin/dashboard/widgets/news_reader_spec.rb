# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::NewsReader, type: :component do
  include WebMock::API

  before do
    WebMock.enable!
    WebMock.reset!
  end
  after { WebMock.disable! }

  # A fresh cache per example keeps the fetch deterministic and isolated.
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  before { allow(Rails).to receive(:cache).and_return(cache) }

  let(:feed) do
    <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        #{entries}
      </feed>
    XML
  end

  let(:entries) do
    (1..count).map do |i|
      content = <<~HTML
        <p><img src="https://alchemy-cms.com/news/#{i}.jpg" alt=""></p>
        <h2>Headline #{i}</h2>
        <p>Summary of news item #{i}.</p>
      HTML
      <<~XML
        <entry>
          <title>News item #{i}</title>
          <link rel="alternate" type="text/html" href="https://alchemy-cms.com/news/#{i}"/>
          <content type="html">#{CGI.escapeHTML(content)}</content>
          <author><name>Jane Doe</name></author>
          <published>2026-06-0#{i}T10:00:00Z</published>
        </entry>
      XML
    end.join
  end

  let(:count) { 3 }

  before do
    stub_request(:get, described_class::FEED_URL).to_return(body: feed)
  end

  subject(:rendered) do
    render_inline(described_class.new)
    page
  end

  it "renders the widget body" do
    expect(rendered).to have_css(".widget-body")
  end

  it "renders the header with an icon" do
    expect(rendered).to have_css(".name .label-with-icon alchemy-icon[name='newspaper']")
    expect(rendered).to have_text(Alchemy.t("admin.dashboard.widgets.news_reader.widget_title"))
  end

  it "renders a link for each entry" do
    expect(rendered).to have_link("News item 1", href: "https://alchemy-cms.com/news/1")
    expect(rendered).to have_link("News item 3", href: "https://alchemy-cms.com/news/3")
  end

  it "opens entry links in a new tab" do
    expect(rendered).to have_css("a[href='https://alchemy-cms.com/news/1'][target='_blank']")
  end

  it "renders the published date of each entry" do
    expect(rendered).to have_text("2026")
  end

  it "renders the author of each entry" do
    expect(rendered).to have_text("Jane Doe")
  end

  it "wraps the entries in a rotating carousel element" do
    expect(rendered).to have_css("alchemy-news-reader .news-reader--item", count: 3)
  end

  it "renders the entry image inline, linked to the post" do
    expect(rendered).to have_css(
      "a.news-reader--image-link[href='https://alchemy-cms.com/news/1'] " \
      "img.news-reader--image[src='https://alchemy-cms.com/news/1.jpg']"
    )
  end

  it "renders the summary from the entry content" do
    expect(rendered).to have_text("Summary of news item 1.")
  end

  it "caches the feed across renders" do
    render_inline(described_class.new)
    render_inline(described_class.new)
    assert_requested(:get, described_class::FEED_URL, times: 1)
  end

  context "when the feed request fails" do
    before do
      stub_request(:get, described_class::FEED_URL).to_timeout
    end

    it "does not cache the failure" do
      render_inline(described_class.new)
      render_inline(described_class.new)
      assert_requested(:get, described_class::FEED_URL, times: 2)
    end
  end

  context "when the feed has more than five entries" do
    let(:count) { 7 }

    it "renders only the first five entries" do
      expect(rendered).to have_link("News item 5")
      expect(rendered).to have_no_link("News item 6")
    end
  end

  context "when the feed request fails" do
    before do
      stub_request(:get, described_class::FEED_URL).to_timeout
    end

    it "renders the empty state instead of raising" do
      expect(rendered).to have_text(Alchemy.t("admin.dashboard.widgets.news_reader.no_news"))
    end
  end

  context "when the feed returns malformed content" do
    before do
      stub_request(:get, described_class::FEED_URL).to_return(body: "<not-a-feed>")
    end

    it "renders the empty state instead of raising" do
      expect(rendered).to have_text(Alchemy.t("admin.dashboard.widgets.news_reader.no_news"))
    end
  end
end
