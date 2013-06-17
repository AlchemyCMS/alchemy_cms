module Alchemy
  class SitePropertiesCreator

    class << self

      def create_properties
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
        YAML.load_file "#{Rails.root}/config/alchemy/site_properties.yml"
      end

    end

  end
end
