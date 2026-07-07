module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class NewsReader < ViewComponent::Base
          MAX_ENTRIES = 5
          CACHE_KEY = "alchemy/dashboard/news_reader"
          CACHE_EXPIRY = 1.hour

          FEED_URL = "https://www.alchemy-cms.com/news"

          def entries
            # Failed fetches return nil and are skipped (skip_nil), so a transient
            # outage does not blank the widget for the whole cache duration.
            @entries ||= Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY, skip_nil: true) do
              fetch_entries
            end || []
          end

          private

          def fetch_entries
            response = Net::HTTP.get(URI(FEED_URL), {"Accept" => "application/atom+xml"})
            doc = Nokogiri.parse(response)
            doc.remove_namespaces!
            doc.xpath("/feed/entry").first(MAX_ENTRIES).map { |entry| parse_entry(entry) }
          rescue => error
            Rails.logger.warn("Alchemy::Admin::Dashboard::Widgets::NewsReader could not load feed: #{error.message}")
            nil
          end

          def parse_entry(entry)
            content = Nokogiri::HTML.fragment(entry.xpath("content").text)
            {
              title: entry.xpath("title").text,
              url: entry.at_xpath("link[@rel='alternate']")&.attr("href") || entry.at_xpath("link")&.attr("href"),
              author: entry.xpath("author/name").text.presence,
              image_url: content.at_css("img")&.attr("src"),
              summary: content.text.squish.presence,
              published_at: published_at(entry)
            }
          end

          def published_at(entry)
            date = entry.xpath("published").text
            ::I18n.l(Date.parse(date), format: :default) if date.present?
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
