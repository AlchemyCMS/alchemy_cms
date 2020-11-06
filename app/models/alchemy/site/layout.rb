# frozen_string_literal: true

module Alchemy
  module Site::Layout
    extend ActiveSupport::Concern
    SITE_DEFINITIONS_FILE = Rails.root.join("config/alchemy/site_layouts.yml")

    module ClassMethods
      # Returns the site layouts definition defined in +site_layouts.yml+ file
      #
      def definitions
        @definitions ||= read_site_definitions
      end

      private

      # Reads the site layouts definition file named +site_layouts.yml+ in +config/alchemy/+
      #
      # It returns empty Array if no file is present
      #
      def read_site_definitions
        YAML.load_file(SITE_DEFINITIONS_FILE) || []
      rescue Errno::ENOENT
        []
      end
    end

    # Returns sites layout definition
    #
    def definition
      self.class.definitions.detect { |l| l["name"] == partial_name } || {}
    end

    # Returns sites page layout names
    #
    # If no site layout file is defined all page layouts are returned
    #
    # @param [Boolean] layoutpages Return layout pages only (default false)
    #
    # @return [Array<String>] Array of page layout names
    #
    def page_layout_names(layoutpages: false)
      page_layout_definitions.select do |layout|
        !!layout["layoutpage"] && layoutpages || !layout["layoutpage"] && !layoutpages
      end.collect { |layout| layout["name"] }
    end

    # Returns sites page layout definitions
    #
    # If no site layout file is defined all page layouts are returned
    #
    def page_layout_definitions
      if definition["page_layouts"].presence
        Alchemy::PageLayout.all.select do |layout|
          layout["name"].in?(definition["page_layouts"])
        end
      else
        Alchemy::PageLayout.all
      end
    end

    # Returns the name for the layout partial
    #
    def partial_name
      name.parameterize.underscore
    end
  end
end
