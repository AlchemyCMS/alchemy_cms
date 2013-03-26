module Alchemy
  module Admin
    class SitesController < ResourcesController

      def configure
        load_resource
        @properties = @site.properties
        render layout: false
      end

      def configure_set
        load_resource
        current_site.properties.each do |property|
          property.value = parse_value(property, params[:properties][property.id.to_s])
          property.save!
        end
        redirect_to admin_sites_path
      end

      private 
      
      def parse_value(property, value)
        if property.property_type == 'boolean'
          value == 'on' ? '1' : '0'
        else
          value
        end
      end

    end
  end
end
