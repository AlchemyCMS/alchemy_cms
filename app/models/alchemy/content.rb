# == Schema Information
#
# Table name: alchemy_contents
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  essence_type :string(255)
#  essence_id   :integer
#  element_id   :integer
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :integer
#  updater_id   :integer
#

module Alchemy
  class Content < ActiveRecord::Base
    include Alchemy::Logger
    include Alchemy::Touching
    include Alchemy::Hints

    # Concerns
    include Alchemy::Content::Factory

    belongs_to :essence, :polymorphic => true, :dependent => :destroy
    belongs_to :element, touch: true

    stampable stamper_class_name: Alchemy.user_class_name

    acts_as_list

    # ActsAsList scope
    def scope_condition
      # Fixes a bug with postgresql having a wrong element_id value, if element_id is nil.
      "element_id = #{element_id || 'null'} AND essence_type = '#{essence_type}'"
    end

    # Validations
    validates :position, uniqueness: {scope: [:element_id, :essence_type]}

    # Essence scopes
    scope :essence_booleans,  -> { where(essence_type: "Alchemy::EssenceBoolean") }
    scope :essence_dates,     -> { where(essence_type: "Alchemy::EssenceDate") }
    scope :essence_files,     -> { where(essence_type: "Alchemy::EssenceFile") }
    scope :essence_htmls,     -> { where(essence_type: "Alchemy::EssenceHtml") }
    scope :essence_links,     -> { where(essence_type: "Alchemy::EssenceLink") }
    scope :essence_pictures,  -> { where(essence_type: "Alchemy::EssencePicture") }
    scope :gallery_pictures,  -> { essence_pictures.where("#{self.table_name}.name LIKE 'essence_picture_%'") }
    scope :essence_richtexts, -> { where(essence_type: "Alchemy::EssenceRichtext") }
    scope :essence_selects,   -> { where(essence_type: "Alchemy::EssenceSelect") }
    scope :essence_texts,     -> { where(essence_type: "Alchemy::EssenceText") }
    scope :named,             ->(name) { where(name: name) }

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

    # The content's view partial is dependent from its name
    #
    # == Define contents
    #
    # Contents are defined in the +config/alchemy/elements.yml+ file
    #
    #     - name: article
    #       contents:
    #       - name: headline
    #         type: EssenceText
    #
    # == Override the view
    #
    # Content partials live in +app/views/alchemy/essences+
    #
    def to_partial_path
      "alchemy/essences/#{essence_partial_name}_view"
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

    # Updates the essence.
    #
    # Called from +Alchemy::Element#update_contents+
    #
    # Adds errors to self.base if essence validation fails.
    #
    def update_essence(params = {})
      raise EssenceMissingError if essence.nil?
      if essence.update(params)
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
    # You can pass an Essence column_name. Default is 'ingredient'
    #
    # ==== Example:
    #
    #   <%= text_field_tag content.form_field_name(:link), content.ingredient %>
    #
    def form_field_name(essence_column = 'ingredient')
      "contents[#{self.id}][#{essence_column}]"
    end

    def form_field_id(essence_column = 'ingredient')
      "contents_#{self.id}_#{essence_column}"
    end

    # Returns a string used as dom id on html elements.
    def dom_id
      return '' if essence.nil?
      "#{essence_partial_name}_#{id}"
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
      return '' if essence.nil?
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

  end
end
