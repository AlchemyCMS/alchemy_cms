# frozen_string_literal: true

module Alchemy
  module Admin
    class EssenceModelsController < Alchemy::Admin::BaseController
      include Alchemy::Admin::ModelsHelper

      authorize_resource class: Alchemy::EssenceModel

      def index
        content = Content.find(params[:content_id])
        model = Object.const_get(content.settings_value(:model).to_s)
        authorize! :manage, model
        settings = get_content_settings(content)
        if settings[:scope]
          model = model.send(settings[:scope].to_sym)
        end
        results = model.ransack(settings[:search_field_name] => params[:term]).result(distinct: true).page(params[:page]).per(per_page)
        render json: {
          :results => get_results_for_select(results, settings),
          :more => params[:page].to_i * per_page < results.total_count.to_i
        }
      end

      def per_page
        5
      end

    end
  end
end
