# frozen_string_literal: true

module Alchemy
  class WildcardUrlMatcher
    attr_reader :page, :params

    def initialize(parent_page = Current.language.root_page)
      @parent_page = parent_page
      @params = ActionController::Parameters.new
      @page = nil
    end

    def call(urlname)
      @page = find_page(urlname)
      self
    end

    private

    # Walks the page tree level by level, matching URL segments against page slugs or wildcard URLs.
    #
    # @return [Alchemy::Page, nil] the matched page or nil if no match
    def find_page(urlname)
      return if urlname.blank? || @parent_page.nil? || wildcard_layout_names.empty?

      segments = urlname.split("/")
      current_parent = @parent_page
      path_prefix = nil
      page = nil

      until segments.empty?
        children = current_parent.children.contentpages

        # Try an exact slug match first
        expected_urlname = [path_prefix, segments.first].compact.join("/")
        page = children.find_by(urlname: expected_urlname)
        if page
          segments = segments.drop(1)
          current_parent = page
          path_prefix = expected_urlname
          next
        end

        # Try children with wildcard_url attributes
        children.where(page_layout: wildcard_layout_names).each do |child|
          page_definition = PageDefinition.get(child.page_layout)
          pattern = page_definition.wildcard_url.pattern

          # a wildcard url pattern can have multiple segments, e.g. ":year/:slug"
          segment_count = pattern.count("/") + 1
          candidate_url = segments.first(segment_count).join("/")

          next unless url_matches_pattern?(candidate_url, pattern)

          extracted_parameters = extract_params_from_url(candidate_url, pattern)
          next unless params_match_constraints?(extracted_parameters, page_definition.wildcard_url.params)

          @params.merge!(extracted_parameters)

          # prepare the data for the next segment loop
          path_prefix = [path_prefix, child.slug].compact.join("/")
          segments = segments.drop(segment_count)
          current_parent = child
          page = child
          break
        end
        return unless page
      end

      page
    end

    # Checks if a URL matches a pattern's structure.
    # Verifies segment count and static segment equality.
    #
    # @param url [String] the URL segment(s) to check, e.g. "2024/my-post"
    # @param pattern [String] the wildcard pattern, e.g. ":year/:slug"
    # @return [Boolean]
    def url_matches_pattern?(url, pattern)
      url_segments = url.split("/")
      pattern_segments = pattern.split("/")
      return false unless url_segments.size == pattern_segments.size

      pattern_segments.each_with_index.all? do |segment, index|
        segment.start_with?(":") || segment == url_segments[index]
      end
    end

    # Extracts named parameters from a URL that matches a pattern.
    #
    # @param url [String] the URL segment(s) to extract from, e.g. "2024/my-post"
    # @param pattern [String] the wildcard pattern, e.g. ":year/:slug"
    # @return [Hash<Symbol, String>] extracted parameter names and values
    def extract_params_from_url(url, pattern)
      url_segments = url.split("/")
      pattern.split("/").each_with_index.each_with_object({}) do |(segment, index), params|
        params[segment[1..].to_sym] = url_segments[index] if segment.start_with?(":")
      end
    end

    # Validates extracted params against wildcard_url params from the page definition.
    # Params can be a simple string or a hash mapping param names to types.
    #
    # @param params [Hash<Symbol, String>] extracted params
    # @param constraints [String, Hash, nil] param definitions
    # @return [Boolean]
    def params_match_constraints?(params, constraints)
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
    # A simple string applies to all params, e.g. params: "integer"
    #
    # @param constraints [String, Hash] param definitions
    # @param params [Hash<Symbol, String>] extracted params
    # @return [Hash<Symbol, String>]
    def normalize_constraints(constraints, params)
      if constraints.is_a?(String)
        params.keys.to_h { |key| [key, constraints] }
      else
        constraints.transform_keys(&:to_sym)
      end
    end

    # Returns the names of all page layouts that have a wildcard_url defined.
    #
    # @return [Array<String>] layout names with wildcard URLs
    def wildcard_layout_names
      @_wildcard_layout_names ||= PageDefinition.all.select { |d| d.wildcard_url&.present? }.map(&:name)
    end
  end
end
