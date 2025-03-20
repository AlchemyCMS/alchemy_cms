# frozen_string_literal: true

module Alchemy
  module Admin
    module Filters
      class Base
        attr_reader :name, :resource_name, :search_form

        def initialize(name:, resource_name:, search_form:)
          @name = name
          @resource_name = resource_name
          @search_form = search_form
        end

        def applied_filter_component(search_filter_params:, resource_url_proxy:, query:)
          Alchemy::Admin::Resource::AppliedFilter.new(
            link: dismiss_filter_url(search_filter_params, resource_url_proxy),
            label: applied_filter_label(search_filter_params[:q][name], query)
          )
        end

        private

        def applied_filter_label(_value, _query)
          translated_name
        end

        def translated_name
          Alchemy.t(:name, scope: [:filters, resource_name, name])
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
