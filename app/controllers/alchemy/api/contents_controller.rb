# frozen_string_literal: true

module Alchemy
  class Api::ContentsController < Api::BaseController
    # Returns all contents as json object
    #
    # You can either load all or only these for :element_id param
    #
    def index
      # Fix for cancancan not able to merge multiple AR scopes for logged in users
      if can? :manage, Alchemy::Content
        @contents = Content.all
      else
        @contents = Content.accessible_by(current_ability, :index)
      end
      if params[:element_id].present?
        @contents = @contents.where(element_id: params[:element_id])
      end
      @contents = @contents.includes(*content_includes)

      render json: @contents, adapter: :json, root: "contents"
    end

    # Returns a json object for content
    #
    # You can either load it from :id param
    # or even more useful via passing the element id and the name of the content
    #
    #   $ bin/rake routes
    #
    # for more infos on how the url looks like.
    #
    def show
      if params[:id]
        @content = Content.where(id: params[:id]).includes(:essence).first
      elsif params[:element_id] && params[:name]
        @content = Content.where(
          element_id: params[:element_id],
          name: params[:name],
        ).includes(*content_includes).first || raise(ActiveRecord::RecordNotFound)
      end
      authorize! :show, @content
      respond_with @content
    end

    private

    def content_includes
      [
        {
          essence: :ingredient_association,
        },
      ]
    end
  end
end
