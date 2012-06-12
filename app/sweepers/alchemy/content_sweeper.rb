module Alchemy
  class ContentSweeper < ActionController::Caching::Sweeper

    observe Element, Page

    def after_create(object)
      expire_contents_displayed_as_select
    end

    def after_update(object)
      if object.class.to_s == "Alchemy::Element"
        expire_cache_for(object.contents)
        expire_contents_displayed_as_select
      elsif object.class.to_s == "Alchemy::Page" && (object.urlname_changed? || object.name_changed?)
        expire_contents_displayed_as_select
      end
    end

    def after_destroy(object)
      if object.class.to_s == "Alchemy::Element"
        expire_cache_for(object.contents)
      elsif object.class.to_s == "Alchemy::Page"
        expire_contents_displayed_as_select
      end
    end

  private

    def expire_cache_for(contents)
      contents.each do |content|
        expire_fragment(content)
      end
    end

    # Expires all EssenceSelect content editor cache fragments.
    def expire_contents_displayed_as_select
      Content.essence_selects.each { |content| expire_fragment(content) }
    end

  end
end
