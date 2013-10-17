require 'acts_as_list'

module Alchemy
  class Content < ActiveRecord::Base
    include Logger

    # Concerns
    include Factory

    attr_accessible(
      :do_not_index,
      :element_id,
      :essence_id,
      :essence_type,
      :ingredient,
      :name
    )

    belongs_to :essence, :polymorphic => true, :dependent => :destroy
    belongs_to :element

    stampable stamper_class_name: Alchemy.user_class_name

    acts_as_list

    def scope_condition
      "element_id = '#{element_id}' AND essence_type = '#{essence_type}'"
    end

    #validates_uniqueness_of :name, :scope => :element_id
    validates_uniqueness_of :position, :scope => [:element_id, :essence_type]

    # Essence scopes
    scope :essence_booleans, where(:essence_type => "Alchemy::EssenceBoolean")
    scope :essence_dates, where(:essence_type => "Alchemy::EssenceDate")
    scope :essence_files, where(:essence_type => "Alchemy::EssenceFile")
    scope :essence_htmls, where(:essence_type => "Alchemy::EssenceHtml")
    scope :essence_links, where(:essence_type => "Alchemy::EssenceLink")
    scope :essence_pictures, where(:essence_type => "Alchemy::EssencePicture")
    scope :gallery_pictures, essence_pictures.where("#{self.table_name}.name LIKE 'essence_picture_%'")
    scope :essence_richtexts, where(:essence_type => "Alchemy::EssenceRichtext")
    scope :essence_selects, where(:essence_type => "Alchemy::EssenceSelect")
    scope :essence_texts, where(:essence_type => "Alchemy::EssenceText")

    class << self
      # Returns the translated label for a content name.
      #
      # Translate it in your locale yml file:
      #
      #   alchemy:
      #     content_names:
      #       foo: Bar
      #
      # Optionally you can scope your content name to an element:
      #
      #   alchemy:
      #     content_names:
      #       article:
      #         foo: Baz
      #
      def translated_label_for(content_name, element_name = nil)
        I18n.t(
          content_name,
          scope: "content_names.#{element_name}",
          default: I18n.t("content_names.#{content_name}", default: content_name.humanize)
        )
      end
    end

    # Settings from the elements.yml definition
    def settings
      return {} if description.blank?
      @settings ||= description['settings']
      return {} if @settings.blank?
      @settings.symbolize_keys
    end

    def siblings
      return [] if !element
      self.element.contents
    end

    # Gets the ingredient from essence
    def ingredient
      return nil if essence.nil?
      essence.ingredient
    end

    # Sets the ingredient from essence
    def ingredient=(value)
      raise EssenceMissingError if essence.nil?
      essence.ingredient = value
    end

    # Calls essence.update_attributes.
    #
    # Called from +Alchemy::Element#save_contents+
    #
    # Adds errors to self.base if essence validation fails.
    #
    def update_essence(params={})
      raise EssenceMissingError if essence.nil?
      if essence.update_attributes(params)
        return true
      else
        errors.add(:essence, :validation_failed)
        return false
      end
    end

    def essence_validation_failed?
      essence.errors.any?
    end

    def has_validations?
      description['validate'].present?
    end

    # Returns a string to be passed to Rails form field tags to ensure we have same params layout everywhere.
    #
    # === Example:
    #
    #   <%= text_field_tag content.form_field_name, content.ingredient %>
    #
    # === Options:
    #
    # You can pass an Essence column_name. Default is self.essence.ingredient_column
    #
    # ==== Example:
    #
    #   <%= text_field_tag content.form_field_name(:link), content.ingredient %>
    #
    def form_field_name(essence_column = self.essence.ingredient_column)
      "contents[content_#{self.id}][#{essence_column}]"
    end

    def form_field_id(essence_column = self.essence.ingredient_column)
      "contents_content_#{self.id}_#{essence_column}"
    end

    # Returns the translated name for displaying in labels, etc.
    def name_for_label
      self.class.translated_label_for(self.name, self.element.name)
    end

    def linked?
      essence && !essence.link.blank?
    end

    # Returns true if this content should be taken for element preview.
    def preview_content?
      !!description['take_me_for_preview']
    end

    # Proxy method that returns the preview text from essence.
    #
    def preview_text(maxlength = 30)
      essence.preview_text(maxlength)
    end

    def essence_partial_name
      essence.partial_name
    end

    def normalized_essence_type
      self.class.normalize_essence_type(self.essence_type)
    end

    def has_custom_tinymce_config?
      settings[:tinymce].present?
    end

    def tinymce_class_name
      if has_custom_tinymce_config?
        "custom_tinymce #{element.name}_#{name}"
      else
        "default_tinymce"
      end
    end

    # Returns the default value from content description
    # If the value is a symbol it gets passed through i18n inside the +alchemy.default_content_texts+ scope
    def default_text(default)
      case default
      when Symbol
        I18n.t(default, scope: :default_content_texts)
      else
        default
      end
    end

    # Returns the hint for this content
    #
    # To add a hint to a content pass +hint: true+ to the element definition in its element.yml
    #
    # Then the hint itself is placed in the locale yml files.
    #
    # Alternativly you can pass the hint itself to the hint key.
    #
    # == Locale Example:
    #
    #   # elements.yml
    #   - name: headline
    #     contents:
    #     - name: headline
    #       type: EssenceText
    #       hint: true
    #
    #   # config/locales/de.yml
    #     de:
    #       content_hints:
    #         headline: Lorem ipsum
    #
    # == Hint Key Example:
    #
    #   - name: headline
    #     contents:
    #     - name: headline
    #       type: EssenceText
    #       hint: Lorem ipsum
    #
    # @return String
    #
    def hint
      hint = definition['hint']
      if hint == true
        I18n.t(name, scope: :content_hints)
      else
        hint
      end
    end

    # Returns true if the element has a hint
    def has_hint?
      hint.present?
    end

  end
end
