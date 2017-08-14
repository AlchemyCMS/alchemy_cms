# frozen_string_literal: true

module Alchemy
  module Site::Layout
    extend ActiveSupport::Concern
    SITE_DEFINITIONS_FILE = Rails.root.join('config/alchemy/site_layouts.yml')

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

    # Returns site's layout definition
    #
    def definition
      self.class.definitions.detect { |l| l['name'] == partial_name }
    end

    # Returns the name for the layout partial
    #
    def partial_name
      name.parameterize.underscore
    end
  end
end
