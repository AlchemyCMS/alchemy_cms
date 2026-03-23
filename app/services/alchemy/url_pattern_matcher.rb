# frozen_string_literal: true

module Alchemy
  class UrlPatternMatcher
    attr_reader :urlname, :language_code, :page, :params

    def initialize(urlname, language_code: Current.language.code)
      @urlname = urlname
      @language_code = language_code
      @params = {}
      @page = find_page
    end

    private

    # Walks the page tree level by level, matching URL segments against page slugs or url_patterns.
    #
    # @return [Alchemy::Page, nil] the matched page or nil if no match
    def find_page
      return if urlname.blank? || pattern_layout_names.empty?

      segments = urlname.split("/")
      root = Page.language_roots.find_by(language_code: language_code)
      return unless root

      parent_id = root.id
      path_prefix = nil
      page = nil

      until segments.empty?
        children = Page.contentpages.where(language_code: language_code, parent_id: parent_id)

        # Try an exact slug match first
        expected_urlname = [path_prefix, segments.first].compact.join("/")
        page = children.find_by(urlname: expected_urlname)
        if page
          segments = segments.drop(1)
          parent_id = page.id
          path_prefix = expected_urlname
          next
        end

        # Try children with url_patterns attributes
        children.where(page_layout: pattern_layout_names).each do |child|
          page_definition = PageDefinition.get(child.page_layout)
          url_pattern = page_definition.url_pattern

          # a url pattern can have multiple segments, e.g. ":year/:slug"
          segment_count = url_pattern.count("/") + 1
          candidate_url = segments.first(segment_count).join("/")
          extracted_parameters = match_url_pattern(candidate_url, url_pattern)

          # skip if the url does not match the pattern or constraints
          next unless extracted_parameters
          next unless satisfies_constraints?(extracted_parameters, page_definition.url_constraints)

          @params.merge!(extracted_parameters)

          # prepare the data for the next segment loop
          path_prefix = [path_prefix, child.slug].compact.join("/")
          segments = segments.drop(segment_count)
          parent_id = child.id
          page = child
          break
        end
        return unless page
      end

      page
    end

    # Matches a URL segment against a pattern like ":year/:slug" and returns
    # the extracted named captures as a hash, e.g. { year: "2024", slug: "my-post" }.
    #
    # @param url [String] the URL segment(s) to match, e.g. "2024/my-post"
    # @param pattern [String] the url_pattern from the page definition, e.g. ":year/:slug"
    # @return [Hash<Symbol, String>, nil] extracted params or nil if no match
    def match_url_pattern(url, pattern)
      regex_str = Regexp.escape(pattern).gsub(/:([a-zA-Z_][a-zA-Z0-9_]*)/) do
        "(?<#{$1}>[^/]+)"
      end

      regex = Regexp.new("\\A#{regex_str}\\z")
      match_data = regex.match(url)
      return nil unless match_data

      match_data.named_captures.transform_keys(&:to_sym)
    end

    # Validates extracted params against url_constraints from the page definition.
    # Constraints can be a simple string or a hash mapping param names to types.
    #
    # @param params [Hash<Symbol, String>] extracted params
    # @param constraints [String, Hash, nil] constraint definitions
    # @return [Boolean]
    def satisfies_constraints?(params, constraints)
      return true if constraints.blank?

      format_matchers = Alchemy.config.format_matchers
      normalize_constraints(constraints, params).all? do |key, type|
        if type.is_a?(Regexp)
          params[key]&.match?(type)
        else
          next true unless format_matchers.respond_to?(type.to_sym)

          params[key]&.match?(format_matchers.public_send(type.to_sym))
        end
      end
    end

    # Normalizes constraints into a hash mapping param names to type strings.
    # A simple string constraint applies to all params, e.g. url_constraints: "integer"
    #
    # @param constraints [String, Hash] constraint definitions
    # @param params [Hash<Symbol, String>] extracted params
    # @return [Hash<Symbol, String>]
    def normalize_constraints(constraints, params)
      if constraints.is_a?(String)
        params.keys.to_h { |key| [key, constraints] }
      else
        constraints.transform_keys(&:to_sym)
      end
    end

    # Returns the names of all page layouts that have a url_pattern defined.
    #
    # @return [Array<String>] layout names with url_patterns
    def pattern_layout_names
      @_pattern_layout_names ||= PageDefinition.all.select { |d| d.url_pattern.present? }.map(&:name)
    end
  end
end
