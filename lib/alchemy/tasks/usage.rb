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
        Alchemy::Element.definitions.reject { |definition| res.map { |e| e["name"] }.include? definition["name"] }.each do |definition|
          res << {"name" => definition["name"], "count" => 0}
        end
        res
      end

      def pages_count_by_type
        res = Alchemy::Page.all
          .select("page_layout, COUNT(*) AS count")
          .group(:page_layout)
          .order("count DESC, page_layout ASC")
          .map { |p| {"page_layout" => p.page_layout, "count" => p.count} }
        Alchemy::PageLayout.all.reject { |page_layout| res.map { |p| p["page_layout"] }.include? page_layout["name"] }.each do |page_layout|
          res << {"page_layout" => page_layout["name"], "count" => 0}
        end
        res
      end
    end
  end
end
