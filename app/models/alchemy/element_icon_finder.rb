module Alchemy
  # Determines the icon name for an element based on its name.
  # Can be configured via +Alchemy.config.element_icon_finder+.
  # The default implementation uses simple pattern matching on remixicon names.
  class ElementIconFinder
    def self.call(element_name)
      case element_name
      when /article/ then "article-line"
      when /audio/, /music/ then "music-2-line"
      when /\bbook\b/ then "book-2-line"
      when /cards/ then "function-line"
      when /card/ then "info-card-line"
      when /code/, /embed/ then "code-block"
      when /color/ then "palette-line"
      when /column/ then "layout-column-line"
      when /divide/, /seperat/ then "separator"
      when /download/ then "file-download-line"
      when /faq/, /comment/ then "question-answer-line"
      when /finder/, /search/ then "seo-line"
      when /foot/ then "layout-bottom-2-line"
      when /galler/ then "gallery-view"
      when /grid/ then "layout-grid-line"
      when /hash/ then "hashtag"
      when /headline/, /heading/ then "heading"
      when /header/, /intro/ then "layout-top-2-line"
      when /help/, /question/ then "questionnaire-line"
      when /link/ then "link"
      when /list/ then "list-check-2"
      when /mail/ then "mail-line"
      when /movie/, /video/, /film/, /play/ then "movie-line"
      when /navi/ then "signpost-line"
      when /news/ then "news-line"
      when /note/ then "sticky-note-line"
      when /picture/, /image/, /photo/ then "image-line"
      when /section/ then "stacked-view"
      when /slider/, /slideshow/ then "slideshow-view"
      when /social/, /community/ then "user-community-line"
      when /price/, /product/ then "price-tag-3-line"
      when /row/ then "layout-row-line"
      when /shop/, /cart/ then "shopping-bag-line"
      when /text/ then "text-block"
      end
    end
  end
end
