# frozen_string_literal: true

module Alchemy
  module SiteRedirects
    extend ActiveSupport::Concern

    included do
      before_action :enforce_primary_host_for_site,
        if: :needs_redirect_to_primary_host?
    end

    private

    def enforce_primary_host_for_site
      redirect_to url_for(host: current_alchemy_site.host), status: :moved_permanently
    end

    def needs_redirect_to_primary_host?
      current_alchemy_site.redirect_to_primary_host? &&
        current_alchemy_site.host != '*' &&
        current_alchemy_site.host != request.host
    end
  end
end
