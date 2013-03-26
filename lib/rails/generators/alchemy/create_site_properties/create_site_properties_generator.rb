require File.join(File.dirname(__FILE__), '../base')
require File.join(File.dirname(__FILE__), '../../../../alchemy/site_properties_creator')

module Alchemy
  module Generators

    class CreateSitePropertiesGenerator < Base
      source_root File.expand_path('../templates', __FILE__)
      desc "Creates site properties in the database based on the site properties configuration file."

      def create_site_properties
        Alchemy::SitePropertiesCreator.create_properties
      end

    end

  end
end

