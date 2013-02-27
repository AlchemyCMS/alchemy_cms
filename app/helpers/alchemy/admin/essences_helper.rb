module Alchemy
  module Admin
    module EssencesHelper

      include Alchemy::EssencesHelper
      include Alchemy::Admin::ContentsHelper

      # Renders the Content editor partial from the given Content.
      # For options see -> render_essence
      def render_essence_editor(content, options = {}, html_options = {})
        render_essence(content, :editor, {:for_editor => options}, html_options)
      end

      # Renders the Content editor partial from essence_type.
      #
      # Options are:
      #   * element (Element) - the Element the contents are in (obligatory)
      #   * type (String) - the type of Essence (obligatory)
      #   * options (Hash):
      #   ** :position (Integer) - The position of the Content inside the Element. I.E. for getting the n-th EssencePicture. Default is 1 (the first)
      #   ** :all (String) - Pass :all to get all Contents of that name. Default false
      #   * editor_options (Hash) - Will be passed to the render_essence_editor partial renderer
      #
      def render_essence_editor_by_type(element, essence_type, options = {}, editor_options = {})
        return warning('Element is nil', _t("no_element_given")) if element.blank?
        return warning('EssenceType is blank', _t("No EssenceType given")) if essence_type.blank?
        defaults = {
          :position => 1,
          :all => false
        }
        options = defaults.merge(options)
        essence_type = Alchemy::Content.normalize_essence_type(essence_type)
        return_string = ""
        if options[:all]
          contents = element.contents.find_all_by_essence_type_and_name(essence_type, options[:all])
          contents.each do |content|
            return_string << render_essence_editor(content, editor_options)
          end
        else
          content = element.contents.find_by_essence_type_and_position(essence_type, options[:position])
          return_string = render_essence_editor(content, editor_options)
        end
        return_string
      end

      # Renders the Content editor partial from the given Element by position (e.g. 1).
      # For options see -> render_essence
      def render_essence_editor_by_position(element, position, options = {})
        ActiveSupport::Deprecation.warn 'Alchemy CMS: render_essence_editor_by_position is not supported anymore and will be removed.'
        if element.blank?
          warning('Element is nil')
          return ""
        end
        content = element.contents.find_by_position(position)
        if content.nil?
          render_missing_content(element, position, options)
        else
          render_essence_editor(content, options)
        end
      end

      # Renders the Content editor partial found in views/contents/ for the content with name inside the passed Element.
      # For options see -> render_essence
      #
      # Content creation on the fly:
      #
      # If you update the elements.yml file after creating an element this helper displays a error message with an option to create the content.
      #
      def render_essence_editor_by_name(element, name, options = {}, html_options = {})
        if element.blank?
          return warning('Element is nil', _t("no_element_given"))
        end
        content = element.content_by_name(name)
        if content.nil?
          render_missing_content(element, name, options)
        else
          render_essence_editor(content, options, html_options)
        end
      end

      # Renders the EssenceSelect editor partial with a form select for storing page ids
      #
      # === Options:
      #
      #   :only            [Hash]     # Pagelayout names. Only pages with this page_layout will be displayed inside the select.
      #   :page_attribute  [Symbol]   # The Page attribute which will be stored. Default is id.
      #   :global          [Boolean]  # Display only global pages. Default is false.
      #   :order_by        [Symbol]   # Order pages by this attribute.
      #
      # NOTE: The +order_by+ option only works if the +only+ or the +global+ option is also set.
      # Then the default ordering is by :name.
      # Otherwise the pages are ordered by their position in the nested set.
      #
      def page_selector(element, content_name, options = {}, select_options = {})
        default_options = {
          :page_attribute => :id,
          :global => false,
          :prompt => _t('Choose page'),
          :order_by => :name
        }
        options = default_options.merge(options)
        content = element.content_by_name(content_name)
        if options[:global] || options[:only].present?
          pages = Page.where({
            :language_id => session[:language_id],
            :layoutpage => options[:global] == true,
            :public => options[:global] == false
          })
          if options[:only].present?
            pages = pages.where({:page_layout => options[:only]})
          end
          pages_options_tags = pages_for_select(pages.order(options[:order_by]), content ? content.ingredient : nil, options[:prompt], options[:page_attribute])
        else
          pages_options_tags = pages_for_select(nil, content ? content.ingredient : nil, options[:prompt], options[:page_attribute])
        end
        options.update(:select_values => pages_options_tags)
        if content.nil?
          render_missing_content(element, content_name, options)
        else
          render_essence_editor(content, options)
        end
      end

      def render_missing_content(element, name, options)
        render :partial => 'alchemy/admin/contents/missing', :locals => {:element => element, :name => name, :options => options}
      end

      def essence_picture_thumbnail(content, options)
        return if content.ingredient.blank?
        image_options = {
          :size => content.ingredient.cropped_thumbnail_size(content.essence.render_size.blank? ? options[:image_size] : content.essence.render_size),
          :crop_from => content.essence.crop_from.blank? ? nil : content.essence.crop_from,
          :crop_size => content.essence.crop_size.blank? ? nil : content.essence.crop_size,
          :crop => content.essence.crop_size.blank? && content.essence.crop_from.blank? ? 'crop' : nil
        }
        image_tag(
          alchemy.thumbnail_path({
            :id => content.ingredient.id,
            :name => content.ingredient.urlname,
            :sh => content.ingredient.security_token(image_options)
          }.merge(image_options)),
          :alt => content.ingredient.name,
          :class => 'img_paddingtop',
          :title => _t("image_name") + ": #{content.ingredient.name}"
        )
      end

    end
  end
end
