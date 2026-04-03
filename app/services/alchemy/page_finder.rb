# frozen_string_literal: true

module Alchemy
  class PageFinder
    attr_reader :params

    def initialize(params: ActionController::Parameters.new)
      @params = params
    end

    def call(urlname)
      return if urlname.blank?

      find_by_urlname(urlname) || find_by_wildcard_url(urlname)
    end

    private

    # Finds a page by exact urlname match within the current language.
    #
    # @return [Alchemy::Page]
    def find_by_urlname(urlname)
      Current.language.pages.contentpages.find_by(urlname: urlname)
    end

    # Walks the page tree level by level, matching URL segments against page slugs or wildcard URLs.
    #
    # @return [Alchemy::Page] the matched page or nil if no match
    def find_by_wildcard_url(urlname)
      root_page = Current.language.root_page
      return if root_page.nil? || wildcard_layout_names.empty?

      segments = urlname.split("/")
      current_parent = root_page
      path_prefix = nil
      page = nil

      until segments.empty?
        children = current_parent.children.contentpages
        expected_urlname = [path_prefix, segments.first].compact.join("/")

        # use only one database query to extract the exact child or children with wildcard_url
        possible_pages = children.where(urlname: expected_urlname)
          .or(children.where(page_layout: wildcard_layout_names))
          .to_a

        # Try an exact slug match first
        page = possible_pages.find { _1.urlname == expected_urlname }
        if page
          segments = segments.drop(1)
          current_parent = page
          path_prefix = expected_urlname
          next
        end

        # Try children with wildcard_url attributes (it is not necessary to select for wildcard urls
        # because the urlname did not match before)
        possible_pages.each do |child|
          pattern = child.wildcard_url.pattern

          # a wildcard url pattern can have multiple segments, e.g. ":year/:slug"
          segment_count = pattern.count("/") + 1
          candidate_url = segments.first(segment_count).join("/")

          extracted_params = extract_matching_params(candidate_url, pattern, child.wildcard_url.params)
          next unless extracted_params

          @params.merge!(ActionController::Parameters.new(extracted_params).permit(*extracted_params.keys))

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

    # Extracts named parameters from a URL matching a wildcard pattern.
    # Returns nil if the URL does not match or constraints are not satisfied.
    #
    # @param url [String] the URL segment(s) to check, e.g. "2024/my-post"
    # @param pattern [String] the wildcard pattern, e.g. ":year/:slug"
    # @param constraints [String, Hash, nil] param definitions
    # @return [Hash<Symbol, String>, nil] extracted params or nil
    def extract_matching_params(url, pattern, constraints)
      url_segments = url.split("/")
      pattern_segments = pattern.split("/")
      return unless url_segments.size == pattern_segments.size

      extracted = {}
      matched = pattern_segments.each_with_index.all? do |pattern_segment, index|
        url_segment = url_segments[index]
        if pattern_segment.start_with?(":")
          key = pattern_segment[1..].to_sym
          extracted[key] = url_segment if matches_constraint?(url_segment, key, constraints)
        else
          pattern_segment == url_segment
        end
      end

      extracted if matched
    end

    # Checks if a param value satisfies its constraint.
    #
    # @param value [String] the param value
    # @param key [Symbol] the param name
    # @param constraints [String, Hash, nil] param definitions
    # @return [Boolean]
    def matches_constraint?(value, key, constraints)
      return true if constraints.blank?

      type = constraints.is_a?(String) ? constraints : constraints[key.to_s] || constraints[key]
      return true if type.nil?
      return value.match?(type) if type.is_a?(Regexp)

      format_matchers = Alchemy.config.format_matchers
      !format_matchers.respond_to?(type.to_sym) || value.match?(format_matchers.public_send(type.to_sym))
    end

    # Returns the names of all page layouts that have a wildcard_url defined.
    #
    # @return [Array<String>] layout names with wildcard URLs
    def wildcard_layout_names
      @_wildcard_layout_names ||= PageDefinition.all.select { |d| d.wildcard_url&.present? }.map(&:name)
    end
  end
end
