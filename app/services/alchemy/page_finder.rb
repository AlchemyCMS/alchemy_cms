# frozen_string_literal: true

module Alchemy
  class PageFinder
    attr_reader :urlname

    Result = Data.define(:page, :extracted_params)

    def initialize(urlname)
      @urlname = urlname
    end

    # @return [PageFinder::Result, nil]
    def call
      return if urlname.blank?

      find_by_urlname || find_by_wildcard_url
    end

    private

    # Finds a page by exact urlname match within the current language.
    def find_by_urlname
      page = Current.language.pages.contentpages.find_by(urlname: urlname)
      Result.new(page: page, extracted_params: ActionController::Parameters.new.permit!) if page
    end

    # Finds a page whose urlname pattern matches the given URL.
    # Loads all pages whose urlname contains a `:param` segment in a
    # single SQL query, then matches each in Ruby.
    #
    # A urlname may contain more than one `:param` segment when a wildcard
    # page is nested under another wildcard page.
    def find_by_wildcard_url
      return unless any_wildcard_definitions?

      # Tree depth of a contentpage = urlname slash count + 1 (skipping the language root)
      page_depth = urlname.count("/") + 1

      wildcard_pages = Current.language.pages.contentpages
        .where("urlname LIKE ?", "%:%")
        .where(depth: page_depth)
        .order(:lft)

      wildcard_pages.each do |wildcard_page|
        matched_params = match_url_pattern(wildcard_page)
        next unless matched_params

        # return the first match
        return Result.new(
          page: wildcard_page,
          extracted_params: ActionController::Parameters.new(matched_params).permit!
        )
      end

      nil
    end

    # Matches the urlname against a page's urlname pattern.
    # Static segments must match literally; each `:param` segment is captured
    # as a single URL segment.
    #
    # @param wildcard_page [Alchemy::Page] a page whose urlname contains one or more `:param` segments
    # @return [Hash<Symbol, String>, nil] matched params or nil
    def match_url_pattern(wildcard_page)
      regex_parts = wildcard_page.urlname.split("/").map do |segment|
        if segment.start_with?(":")
          # create a named capture group for the segment e.g. ":slug" => "(?<slug>.+)"
          "(?<#{segment[1..]}>[\\w\\-]+)"
        else
          # only return the current segment and escape any special regex characters
          Regexp.escape(segment)
        end
      end

      # connect regex parts and match them against the urlname
      match = Regexp.new("\\A#{regex_parts.join("/")}\\z").match(urlname)

      # extract the named capture groups as parameters
      match&.named_captures&.symbolize_keys!
    end

    # @return [Boolean] whether any page definition declares a wildcard_url
    def any_wildcard_definitions?
      PageDefinition.all.any?(&:wildcard_url)
    end
  end
end
