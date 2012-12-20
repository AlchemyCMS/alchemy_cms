module Alchemy
  module Admin
    class ElementsController < Alchemy::Admin::BaseController

      cache_sweeper Alchemy::ContentSweeper, :only => [:create, :update, :destroy]

      def index
        @page = Page.find(params[:page_id], :include => {:elements => :contents})
        @cells = @page.cells
        if @cells.blank?
          @elements = @page.elements.not_trashed
        else
          @elements = @page.elements_grouped_by_cells
        end
        render :layout => false
      end

      def list
        @page_id = params[:page_id]
        if @page_id.blank? && !params[:page_urlname].blank?
          @page_id = Page.find_by_urlname_and_language_id(params[:page_urlname], session[:language_id]).id
        end
        @elements = Element.published.find_all_by_page_id(@page_id)
      end

      def new
        @page = Page.find_by_id(params[:page_id])
        @element = @page.elements.build
        @elements = Element.all_for_page(@page)
        clipboard_elements = get_clipboard[:elements]
        unless clipboard_elements.blank?
          @clipboard_items = Element.all_from_clipboard_for_page(clipboard_elements, @page)
        end
        render :layout => false
      end

      # Creates a element as discribed in config/alchemy/elements.yml on page via AJAX.
      def create
        @page = Page.find(params[:element][:page_id])
        Element.transaction do
          if @paste_from_clipboard = params[:paste_from_clipboard].present?
            @element = paste_element_from_clipboard
            @cell = @element.cell
          else
            @element = Element.new_from_scratch(params[:element])
            if @page.can_have_cells?
              @cell = find_or_create_cell
              @element.cell = @cell
            end
            @element.save
          end
          if @insert_at_top = @page.definition['insert_elements_at'] == 'top'
            @element.move_to_top
          end
        end
        @cell_name = @cell.nil? ? "for_other_elements" : @cell.name
        if @element.valid?
          render :action => :create
        else
          render_remote_errors(@element, params[:paste_from_clipboard].nil? ? nil : '#paste_element_errors')
        end
      end

      # Saves all contents in the elements by calling save_contents.
      # And then updates the element itself.
      def update
        @element = Element.find_by_id(params[:id])
        if @element.save_contents(params)
          @page = @element.page
          @element_validated = @element.update_attributes!(params[:element])
        else
          @element_validated = false
          @notice = t('Validation failed')
          @error_message = "<h2>#{@notice}</h2><p>#{t(:content_validations_headline)}</p>".html_safe
        end
      end

      # Trashes the Element instead of deleting it.
      def trash
        @element = Element.find(params[:id])
        @page = @element.page
        @element.trash
      end

      def order
        params[:element_ids].each do |element_id|
          element = Element.find(element_id)
          if element.trashed?
            element.page_id = params[:page_id]
            element.cell_id = params[:cell_id]
            element.insert_at
          end
          element.move_to_bottom
        end
      end

      def fold
        @element = Element.find(params[:id])
        @page = @element.page
        @element.folded = !@element.folded
        @element.save
      end

    private

      # Returns the cell for element name in params.
      # Creates the cell if necessary.
      def find_or_create_cell
        if @paste_from_clipboard
          element_with_cell_name = params[:paste_from_clipboard]
        else
          element_with_cell_name = params[:element][:name]
        end
        return nil if element_with_cell_name.blank?
        return nil unless element_with_cell_name.include?('#')
        cell_name = element_with_cell_name.split('#').last
        cell_definition = Cell.definition_for(cell_name)
        if cell_definition.blank?
          raise CellDefinitionError, "Cell definition not found for #{cell_name}"
        end
        @page.cells.find_or_create_by_name(cell_definition['name'])
      end

      def element_from_clipboard
        @clipboard = get_clipboard
        @clipboard.get(:elements, params[:paste_from_clipboard])
      end

      def paste_element_from_clipboard
        @source_element = Element.find(element_from_clipboard[:id])
        new_attributes = {:page_id => @page.id}
        if @page.can_have_cells?
          new_attributes = new_attributes.merge({:cell_id => find_or_create_cell.try(:id)})
        end
        element = Element.copy(@source_element, new_attributes)
        cut_element if element_from_clipboard[:action] == 'cut'
        element
      end

      def cut_element
        @cutted_element_id = @source_element.id
        @clipboard.remove :elements, @source_element.id
        @source_element.destroy
      end

    end
  end
end
