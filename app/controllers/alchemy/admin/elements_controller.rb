# frozen_string_literal: true

module Alchemy
  module Admin
    class ElementsController < Alchemy::Admin::BaseController
      before_action :load_element, only: [:update, :destroy, :fold, :publish]
      authorize_resource class: Alchemy::Element

      def index
        @page_version = PageVersion.find(params[:page_version_id])
        @page = @page_version.page
        elements = @page_version.elements.order(:position).includes(*element_includes)
        @elements = elements.not_nested.unfixed
        @fixed_elements = elements.not_nested.fixed
        load_clipboard_items
      end

      def new
        @page_version = PageVersion.find(params[:page_version_id])
        @page = @page_version.page
        @parent_element = Element.find_by(id: params[:parent_element_id])
        @elements = @page.available_elements_within_current_scope(@parent_element)
        @element = @page_version.elements.build
        load_clipboard_items
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
          if @page.definition["insert_elements_at"] == "top"
            @insert_at_top = true
            @element.position = 1
          end
        end
        if @element.save
          render :create
        else
          @element.page_version = @page_version
          @elements = @page.available_element_definitions
          load_clipboard_items
          render :new
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
            ingredientsWithErrors: @element.ingredients_with_errors.map(&:id),
            errors: @element.ingredient_error_messages
          }
        end
      end

      def destroy
        @richtext_ids = @element.richtext_ingredients_ids
        @element.destroy
        @notice = Alchemy.t("Successfully deleted element") % {element: @element.display_name}
      end

      def publish
        @element.update(public: !@element.public?)
      end

      def order
        @parent_element = Element.find_by(id: params[:parent_element_id])
        Element.transaction do
          params.fetch(:element_ids, []).each.with_index(1) do |element_id, position|
            # We need to set the parent_element_id, because we might have dragged the
            # element over from another nestable element
            Element.find_by(id: element_id).update_columns(
              parent_element_id: params[:parent_element_id],
              position: position
            )
          end
          # Need to manually touch the parent because Rails does not do it
          # with the update_columns above
          @parent_element&.touch
        end
      end

      # Toggle folds the element and persists the state in the db
      #
      def fold
        @page = @element.page
        # We do not want to trigger the touch callback or any validations
        @element.update_columns(folded: !@element.folded)
        # Fold all nested elements if folded
        if @element.folded?
          ids = collapse_nested_elements_ids(@element)
          Alchemy::Element.where(id: ids).update_all(folded: true)
        end

        render json: {
          folded: @element.folded,
          title: Alchemy.t(@element.folded? ? :show_element_content : :hide_element_content)
        }
      end

      private

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

      def load_clipboard_items
        @clipboard = get_clipboard("elements")
        @clipboard_items = Element.all_from_clipboard_for_page(@clipboard, @page)
      end

      def element_from_clipboard
        @element_from_clipboard ||= begin
          @clipboard = get_clipboard("elements")
          @clipboard.detect { |item| item["id"].to_i == params[:paste_from_clipboard].to_i }
        end
      end

      def paste_element_from_clipboard
        @source_element = Element.find(element_from_clipboard["id"])
        element = Element.copy(
          @source_element,
          {
            parent_element_id: create_element_params[:parent_element_id],
            page_version_id: @page_version.id
          }
        )
        if element_from_clipboard["action"] == "cut"
          @cut_element_id = @source_element.id
          @clipboard.delete_if { |item| item["id"] == @source_element.id.to_s }
          @source_element.destroy
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
