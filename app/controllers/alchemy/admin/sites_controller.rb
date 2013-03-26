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
        params[:properties].each do |name, value|
          property = @site.properties.where(name: name).first
          property.value = value
          property.save!
        end
        redirect_to admin_sites_path
      end

    end
  end
end
