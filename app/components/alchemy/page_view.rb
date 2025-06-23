module Alchemy
  # Renders the ViewComponent for current page.
  #
  class PageView < ViewComponent::Base
    erb_template <<-HTML
      <% elements.each do |element| %>
        <%= render element %>
      <% end %>
    HTML

    attr_reader :page, :elements_finder

    def initialize(page, elements_finder: Alchemy::ElementsFinder)
      @page = page
      @elements_finder = elements_finder
    end

    def elements(options = {})
      finder = elements_finder.new(options)

      page_version = if Alchemy::Current.preview_page?
        page.draft_version
      else
        page.public_version
      end

      finder.elements(page_version: page_version)
    end
  end
end
