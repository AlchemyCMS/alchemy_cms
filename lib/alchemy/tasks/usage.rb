# frozen_string_literal: true

module Alchemy
  module Tasks
    module Usage
      extend self

      def elements_count_by_name
        res = Alchemy::Element.all
          .select("name, COUNT(*) AS count")
          .group(:name)
          .order("count DESC, name ASC")
          .map { |e| {"name" => e.name, "count" => e.count} }
        Alchemy::Element.definitions.map do |definition|
          count = res.find { |r| r["name"] == definition["name"] }&.fetch("count") || 0
          definition["count"] = count
          definition
        end.sort_by { |r| -1 * r["count"] }
      end

      def pages_count_by_type
        res = Alchemy::Page.all
          .select("page_layout, COUNT(*) AS count")
          .group(:page_layout)
          .order("count DESC, page_layout ASC")
          .map { |p| {"page_layout" => p.page_layout, "count" => p.count} }
        Alchemy::PageLayout.all.reject { |page_layout| res.map { |p| p["page_layout"] }.include? page_layout["name"] }.sort_by { |d| d["name"] }.each do |page_layout|
          res << {"page_layout" => page_layout["name"], "count" => 0}
        end
        res
      end
    end
  end
end
