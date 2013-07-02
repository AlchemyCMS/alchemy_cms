module Alchemy
  module Site::Layout
    extend ActiveSupport::Concern
    SITE_LAYOUTS_FILE = Rails.root.join('config/alchemy/site_layouts.yml')

    module ClassMethods
      # Returns the site layouts definition defined in +site_layouts.yml+ file
      #
      def layout_definitions
        @layout_definitions ||= read_site_layouts
      end

    private

      # Reads the site layouts definition file named +site_layouts.yml+ in +config/alchemy/+
      #
      # It returns empty Array if no file is present
      #
      def read_site_layouts
        YAML.load_file(SITE_LAYOUTS_FILE) || []
      rescue Errno::ENOENT
        []
      end
    end

    # Returns site's layout definition
    #
    def layout_definition
      self.class.layout_definitions.detect { |l| l['name'] == layout_partial_name }
    end

    # Returns the name for the layout partial
    #
    def layout_partial_name
      name.parameterize.underscore
    end
  end
end
