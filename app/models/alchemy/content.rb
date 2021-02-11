# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_contents
#
#  id           :integer          not null, primary key
#  name         :string
#  essence_type :string           not null
#  essence_id   :integer          not null
#  element_id   :integer          not null
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  creator_id   :integer
#  updater_id   :integer
#

module Alchemy
  class Content < BaseRecord
    include Alchemy::Logger
    include Alchemy::Hints

    # Concerns
    include Alchemy::Content::Factory

    belongs_to :essence, polymorphic: true, dependent: :destroy, inverse_of: :content
    belongs_to :element, touch: true, inverse_of: :contents
    has_one :page, through: :element

    # Essence scopes
    scope :essence_booleans, -> { where(essence_type: "Alchemy::EssenceBoolean") }
    scope :essence_dates, -> { where(essence_type: "Alchemy::EssenceDate") }
    scope :essence_files, -> { where(essence_type: "Alchemy::EssenceFile") }
    scope :essence_htmls, -> { where(essence_type: "Alchemy::EssenceHtml") }
    scope :essence_links, -> { where(essence_type: "Alchemy::EssenceLink") }
    scope :essence_pictures, -> { where(essence_type: "Alchemy::EssencePicture") }
    scope :essence_richtexts, -> { where(essence_type: "Alchemy::EssenceRichtext") }
    scope :essence_selects, -> { where(essence_type: "Alchemy::EssenceSelect") }
    scope :essence_texts, -> { where(essence_type: "Alchemy::EssenceText") }
    scope :named, ->(name) { where(name: name) }
    scope :available, -> { published }
    scope :published, -> { joins(:element).merge(Element.published) }
    scope :not_restricted, -> { joins(:element).merge(Element.not_restricted) }

    delegate :restricted?, to: :page, allow_nil: true
    delegate :public?, to: :element, allow_nil: true

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
        Alchemy.t(
          content_name,
          scope: "content_names.#{element_name}",
          default: Alchemy.t("content_names.#{content_name}", default: content_name.humanize),
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
      return {} if definition.blank?

      @settings ||= definition.fetch(:settings, {})
    end

    # Fetches value from settings
    #
    # @param key [Symbol]               - The hash key you want to fetch the value from
    # @param options [Hash]             - An optional Hash that can override the settings.
    #                                     Normally passed as options hash into the content
    #                                     editor view.
    def settings_value(key, options = {})
      settings.update(options || {}).symbolize_keys[key.to_sym]
    end

    def siblings
      return [] if !element

      element.contents
    end

    # Gets the ingredient from essence
    def ingredient
      return nil if essence.nil?

      essence.ingredient
    end

    # Serialized object representation for json api
    #
    def serialize
      {
        name: name,
        value: serialized_ingredient,
        link: essence.try(:link),
      }.delete_if { |_k, v| v.blank? }
    end

    # Ingredient value from essence for json api
    #
    # If the essence responds to +serialized_ingredient+ method it takes this
    # otherwise it uses the ingredient column.
    #
    def serialized_ingredient
      essence.try(:serialized_ingredient) || ingredient
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
        true
      else
        errors.add(:essence, :validation_failed)
        false
      end
    end

    def essence_validation_failed?
      essence.errors.any?
    end

    def has_validations?
      definition["validate"].present?
    end

    # Returns a string used as dom id on html elements.
    def dom_id
      return "" if essence.nil?

      "#{essence_partial_name}_#{id}"
    end

    # Returns the translated name for displaying in labels, etc.
    def name_for_label
      self.class.translated_label_for(name, element.name)
    end

    def linked?
      essence && !essence.link.blank?
    end

    def deprecated?
      !!definition["deprecated"]
    end

    # Returns true if this content should be taken for element preview.
    def preview_content?
      !!definition["as_element_title"]
    end

    # Proxy method that returns the preview text from essence.
    #
    def preview_text(maxlength = 30)
      essence.preview_text(maxlength)
    end

    def essence_partial_name
      return "" if essence.nil?

      essence.partial_name
    end

    def normalized_essence_type
      self.class.normalize_essence_type(essence_type)
    end

    # Returns true if there is a tinymce setting defined on the content definiton
    # or if the +essence.has_tinymce?+ returns true.
    def has_tinymce?
      settings[:tinymce].present? || (essence.present? && essence.has_tinymce?)
    end

    # Returns true if there is a tinymce setting defined that contains settings.
    def has_custom_tinymce_config?
      settings[:tinymce].is_a?(Hash)
    end

    # Returns css class names for the content textarea.
    def tinymce_class_name
      "has_tinymce" + (has_custom_tinymce_config? ? " #{element.name}_#{name}" : "")
    end

    # Returns the default value from content definition
    #
    # If the value is a symbol it gets passed through i18n
    # inside the +alchemy.default_content_texts+ scope
    def default_value(default = definition[:default])
      case default
      when Symbol
        Alchemy.t(default, scope: :default_content_texts)
      else
        default
      end
    end
  end
end
