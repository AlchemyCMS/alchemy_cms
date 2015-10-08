module Alchemy
  module Admin
    class SitesController < ResourcesController
      def select
        authorize! :select, :alchemy_admin_site

        session[:site_id] = requested_site_id
        do_redirect_to params[:redirect_to]
      end

      private

      def requested_site_id
        params.fetch(:id)
      end
    end
  end
end
