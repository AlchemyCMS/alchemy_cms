module Alchemy
  class ElementsController < Alchemy::BaseController
    load_and_authorize_resource
    layout false

    rescue_from CanCan::AccessDenied do |exception|
      raise ActiveRecord::RecordNotFound
    end

    # == Renders the element view partial
    #
    # === Accepted Formats
    #
    # * html
    # * js (Tries to replace a given +container_id+ with the elements view partial content via jQuery.)
    # * json (A JSON object that includes all contents and their ingredients)
    #
    def show
      @page = @element.page
      @options = params[:options]

      respond_to do |format|
        format.html
        format.js { @container_id = params[:container_id] }
        format.json do
          render json: @element.to_json(
            only: [:id, :name, :updated_at],
            methods: [:tag_list],
            include: {
              contents: {
                only: [:id, :name, :updated_at, :essence_type],
                methods: [:ingredient],
                include: {
                  essence: {
                    except: [:created_at, :creator_id, :public, :updater_id]
                  }
                }
              }
            }
          )
        end
      end
    end

  end
end
