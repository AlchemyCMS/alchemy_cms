# frozen_string_literal: true

module Alchemy
  class Page < BaseRecord
    module PageNatures
      extend ActiveSupport::Concern

      # Determines if this page has a public version and this version is public.
      #
      # @see PageVersion#public?
      # @returns Boolean
      def public?
        language.public? && !!public_version&.public?
      end

      # Cache-Control max-age duration in seconds.
      #
      # You can set this via the `ALCHEMY_PAGE_CACHE_MAX_AGE` environment variable,
      # in the `Alchemy.config.page_cache_max_age` configuration option,
      # or in the pages definition in `config/alchemy/page_layouts.yml` file.
      #
      # Defaults to 600 seconds.
      def expiration_time
        return 0 unless cache_page?

        if definition.cache.to_s.match?(/\d+/)
          definition.cache.to_i
        else
          Alchemy.config.page_cache.max_age
        end
      end

      def rootpage?
        !new_record? && parent_id.blank?
      end

      def folded?(user_id)
        return unless Alchemy.user_class < ActiveRecord::Base

        if folded_pages.loaded?
          folded_pages.any? { |p| p.folded && p.user_id == user_id }
        else
          folded_pages.where(user_id: user_id, folded: true).any?
        end
      end

      # Returns an Array of Alchemy roles which are able to edit this template
      #
      #     # config/alchemy/page_layouts.yml
      #     - name: contact
      #       editable_by:
      #         - freelancer
      #         - admin
      #
      # @returns Array
      #
      def has_limited_editors?
        definition.editable_by.present?
      end

      def editor_roles
        return unless has_limited_editors?

        definition.editable_by
      end

      # True if page locked_at timestamp and locked_by id are set
      def locked?
        locked_by? && locked_at?
      end

      # Returns a Hash describing the status of the Page.
      #
      def status
        {
          public: public?,
          locked: locked?,
          restricted: restricted?
        }
      end

      # Returns the long translated status message for given status type.
      #
      # @param [Symbol] status_type
      #
      def status_message(status_type)
        Alchemy.t(status[status_type].to_s, scope: "page_states.#{status_type}")
      end

      # Returns the sort translated status title for given status type.
      #
      # @param [Symbol] status_type
      #
      def status_title(status_type)
        Alchemy.t(status[status_type].to_s, scope: "page_status_titles.#{status_type}")
      end

      # Returns the self#page_layout definition from config/alchemy/page_layouts.yml file.
      def definition
        definition = PageDefinition.get(page_layout)
        if definition.nil?
          Logger.warn "Page definition for '#{page_layout}' not found. Please check page_layouts.yml file."
          return PageDefinition.new
        end
        definition
      end

      # Returns translated name of the pages page_layout value.
      # Page layout names are defined inside the config/alchemy/page_layouts.yml file.
      # Translate the name in your config/locales language yml file.
      def layout_display_name
        Alchemy.t(page_layout, scope: "page_layout_names")
      end

      # Returns the name for the layout partial
      #
      def layout_partial_name
        page_layout.parameterize.underscore
      end

      # Returns the version string that's taken for Rails' recycable cache key.
      #
      def cache_version
        last_modified_at&.to_s
      end

      # Returns the timestamp that the page was last modified at, regardless of through
      # publishing or editing page, or through a change of related objects through ingredients.
      # Respects the public version not changing if editing a preview.
      #
      # In preview mode, it will take the draft version's updated_at timestamp.
      # In public mode, it will take the public version's updated_at timestamp.
      #
      def last_modified_at
        relevant_page_version = (Current.preview_page == self) ? draft_version : public_version
        relevant_page_version&.updated_at
      end

      # Returns true if the page cache control headers should be set.
      #
      # == Disable Alchemy's page caching globally
      #
      #     # config/alchemy/config.yml
      #     ...
      #     cache_pages: false
      #
      # == Disable caching on page layout level
      #
      #     # config/alchemy/page_layouts.yml
      #     - name: contact
      #       cache: false
      #
      # == Note:
      #
      # This only sets the cache control headers and skips rendering of the page body,
      # if the cache is fresh.
      # This does not disable the fragment caching in the views.
      # So if you don't want a page and it's elements to be cached,
      # then be sure to not use <% cache element %> in the views.
      #
      # @returns Boolean
      #
      def cache_page?
        return false if !public? || restricted?

        definition.cache != false && definition.searchresults != true
      end
    end
  end
end
