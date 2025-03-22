# frozen_string_literal: true

module Alchemy
  module Admin
    module Filters
      class Base
        attr_reader :name, :resource_name

        def initialize(name:, resource_name:)
          @name = name
          @resource_name = resource_name
        end

        private

        def translated_name
          Alchemy.t(:name, scope: [:filters, resource_name, name], default: name.to_s.humanize)
        end

        def dismiss_filter_url(search_filter_params, resource_url_proxy)
          tmp_params = search_filter_params.dup
          tmp_params[:q] = tmp_params[:q].except(name)
          resource_url_proxy.url_for(
            {action: "index"}.merge(tmp_params.except(:page))
          )
        end
      end
    end
  end
end
