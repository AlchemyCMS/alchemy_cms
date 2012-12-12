module Alchemy
  class ElementsController < Alchemy::BaseController

    filter_access_to :show, :attribute_check => true, :model => Alchemy::Element, :load_method => :load_element
    layout false

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
                    except: [:created_at, :creator_id, :do_not_index, :public, :updater_id]
                  }
                }
              }
            }
          )
        end
      end
    end

  private

    def load_element
      element = Element.available
      if !current_user
        element = element.not_restricted
      end
      @element = element.find(params[:id])
    end

  end
end
