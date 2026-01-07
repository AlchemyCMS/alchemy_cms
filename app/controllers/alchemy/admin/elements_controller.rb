# frozen_string_literal: true

module Alchemy
  module Admin
    class ElementsController < Alchemy::Admin::BaseController
      helper Alchemy::Admin::IngredientsHelper

      before_action :load_page_and_version, only: [:index, :new]
      include Alchemy::Admin::Clipboard

      before_action :load_element, only: [:update, :destroy, :collapse, :expand, :publish]
      authorize_resource class: Alchemy::Element

      def index
        elements = @page_version.elements.order(:position).includes(*element_includes)
        @elements = elements.not_nested.unfixed
        @fixed_elements = elements.not_nested.fixed
      end

      def new
        @parent_element = Element.find_by(id: params[:parent_element_id])
        @elements = @page.available_elements_within_current_scope(@parent_element)
        @element = @page_version.elements.build
        clipboard_items
      end

      # Creates a element as discribed in config/alchemy/elements.yml on page via AJAX.
      def create
        @page_version = PageVersion.find(params[:element][:page_version_id])
        @page = @page_version.page
        Element.transaction do
          @paste_from_clipboard = params[:paste_from_clipboard].present?
          @element = if @paste_from_clipboard
            paste_element_from_clipboard
          else
            Element.new(create_element_params)
          end
          if @page.definition.insert_elements_at == "top"
            @insert_at_top = true
            @element.position = 1
          end
        end
        if @element.save
          render :create, status: 201
        else
          @element.page_version = @page_version
          @elements = @page.available_element_definitions
          render :new, status: 422
        end
      end

      # Updates the element and all ingredients in the element.
      #
      def update
        if @element.update(element_params)
          render json: {
            notice: Alchemy.t(:element_saved),
            previewText: Rails::Html::SafeListSanitizer.new.sanitize(@element.preview_text),
            ingredientAnchors: @element.ingredients.select { |i| i.settings[:anchor] }.map do |ingredient|
              {
                ingredientId: ingredient.id,
                active: ingredient.dom_id.present?
              }
            end
          }
        else
          @warning = Alchemy.t("Validation failed")
          render json: {
            warning: @warning,
            errorMessage: Alchemy.t(:ingredient_validations_headline),
            ingredientsWithErrors: @element.ingredients_with_errors.map do |ingredient|
              {
                id: ingredient.id,
                errorMessage: ingredient.errors.messages[:value].to_sentence
              }
            end
          }, status: 422
        end
      end

      def destroy
        @element.destroy

        render json: {
          message: Alchemy.t("Successfully deleted element") % {element: @element.display_name}
        }
      end

      def publish
        @element.public = !@element.public?
        @element.save(validate: false)
        render json: {
          public: @element.public?,
          label: @element.public? ? Alchemy.t(:hide_element) : Alchemy.t(:show_element)
        }
      end

      def order
        @element = Element.find(params[:element_id])

        # Update position
        @element.parent_element_id = params[:parent_element_id] if params.key?(:parent_element_id)
        @element.position = params[:position]

        # Skip validations when updating position, since new records may not yet meet all
        # validation requirements.
        @element.save(validate: false)

        render json: {
          message: Alchemy.t(:successfully_saved_element_position),
          preview_text: @element.preview_text
        }
      end

      # Collapses the element, all nested elements and persists the state in the db
      #
      def collapse
        # We do not want to trigger the touch callback or any validations
        @element.update_columns(folded: true)
        # Collapse all nested elements
        nested_elements_ids = collapse_nested_elements_ids(@element)
        Alchemy::Element.where(id: nested_elements_ids).update_all(folded: true)

        render json: {
          nestedElementIds: nested_elements_ids,
          title: Alchemy.t(@element.folded? ? :show_element_content : :hide_element_content)
        }
      end

      # Expands the element, all parents and persists the state in the db
      #
      def expand
        # We do not want to trigger the touch callback or any validations
        @element.update_columns(folded: false)
        # We want to expand the upper most parent first in order to prevent
        # re-painting issues in the browser
        parent_element_ids = @element.parent_element_ids.reverse
        Alchemy::Element.where(id: parent_element_ids).update_all(folded: false)

        render json: {
          parentElementIds: parent_element_ids,
          title: Alchemy.t(@element.folded? ? :show_element_content : :hide_element_content)
        }
      end

      private

      def load_page_and_version
        @page_version = PageVersion.find(params[:page_version_id])
        @page = @page_version.page
      end

      def collapse_nested_elements_ids(element)
        ids = []
        element.all_nested_elements.includes(:all_nested_elements).reject(&:compact?).each do |nested_element|
          ids.push nested_element.id if nested_element.expanded?
          ids.concat collapse_nested_elements_ids(nested_element) if nested_element.all_nested_elements.reject(&:compact?).any?
        end
        ids
      end

      def element_includes
        [
          {
            ingredients: :related_object
          },
          :tags,
          {
            all_nested_elements: [
              {
                ingredients: :related_object
              },
              :tags
            ]
          }
        ]
      end

      def load_element
        @element = Element.find(params[:id])
      end

      def clipboard_items
        @clipboard_items = Element.all_from_clipboard_for_page(clipboard, @page)
      end

      def paste_element_from_clipboard
        @source_element = Element.find(item_from_clipboard["id"])
        element = Element.copy(
          @source_element,
          {
            parent_element_id: create_element_params[:parent_element_id],
            page_version_id: @page_version.id
          }
        )
        if item_from_clipboard["action"] == "cut"
          @cut_element_id = @source_element.id
          remove_resource_from_clipboard(@source_element)
        end
        element
      end

      def element_params
        params.fetch(:element, {}).permit(:tag_list, ingredients_attributes: {})
      end

      def create_element_params
        params.require(:element).permit(:name, :page_version_id, :parent_element_id)
      end
    end
  end
end
