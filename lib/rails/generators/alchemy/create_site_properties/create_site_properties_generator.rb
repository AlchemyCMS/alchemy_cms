require File.join(__FILE__, '../../base')
module Alchemy
  module Generators
    class CreateSitePropertiesGenerator < Base
      source_root File.expand_path('../templates', __FILE__)
      desc "does stuff"

      def create_site_properties
        Alchemy::Site.all.each do |site|
          site_properties.each do |property|
            attributes = {site_id: site.id, name: property['name'], property_type: property['type']}
            unless Alchemy::SiteProperty.exists?(attributes)
              Alchemy::SiteProperty.create(attributes)
            end
          end
        end
      end

      private

      def site_properties
        load_alchemy_yaml("site_properties.yml")
      end

    end
  end
end

