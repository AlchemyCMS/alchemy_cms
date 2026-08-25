module Alchemy
  class Menubar < ViewComponent::Base
    attr_reader :page

    delegate :alchemy, :can?, to: :helpers

    def initialize(page: Alchemy::Current.page)
      @page = page
    end

    def render?
      page && !Alchemy::Current.preview_page? && can?(:edit_content, page)
    end
  end
end
