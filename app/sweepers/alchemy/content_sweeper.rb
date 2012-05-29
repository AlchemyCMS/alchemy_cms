module Alchemy
  class ContentSweeper < ActionController::Caching::Sweeper

    observe Element, Page

    def after_create(object)
      if object.class.to_s == "Alchemy::Page"
        expire_contents_displayed_as_select(object)
      end
    end

    def after_update(object)
      if object.class.to_s == "Alchemy::Element"
        expire_cache_for(object.contents)
      elsif object.class.to_s == "Alchemy::Page"
        expire_contents_displayed_as_select(object)
      end
    end

    def after_destroy(object)
      if object.class.to_s == "Alchemy::Element"
        expire_cache_for(object.contents)
      elsif object.class.to_s == "Alchemy::Page"
        expire_contents_displayed_as_select(object)
      end
    end

  private

    def expire_cache_for(contents)
      contents.each do |content|
        expire_fragment(content)
      end
    end

    # Expires all content editor cache fragments that have a :display_as => :select setting
    def expire_contents_displayed_as_select(page)
      return unless page.urlname_changed? || page.name_changed?
      Content.essence_texts.all.select { |c| c.settings[:display_as] == 'select'}.each do |content|
        expire_fragment(content)
      end
    end

  end
end
