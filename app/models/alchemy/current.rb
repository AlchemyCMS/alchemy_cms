module Alchemy
  class Current < ActiveSupport::CurrentAttributes
    attribute :preview_page, :page, :language, :site

    def language
      super || Language.default
    end

    def site
      super || Site.first
    end

    def preview_page=(page)
      super

      self.page = page
      self.language = page&.language
      self.site = page&.site
    end

    def preview_page?(page = Current.page)
      return false if preview_page.nil?
      preview_page == page
    end
  end
end
