module Alchemy
  class Content < ActiveRecord::Base

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

    stampable(:stamper_class_name => 'Alchemy::User')

    acts_as_list

    def scope_condition
      "element_id = '#{element_id}' AND essence_type = '#{essence_type}'"
    end

    #validates_uniqueness_of :name, :scope => :element_id
    validates_uniqueness_of :position, :scope => [:element_id, :essence_type]

    scope :essence_pictures, where(:essence_type => "Alchemy::EssencePicture")
    scope :gallery_pictures, essence_pictures.where("#{self.table_name}.name LIKE 'essence_picture_%'")
    scope :essence_texts, where(:essence_type => "Alchemy::EssenceText")
    scope :essence_richtexts, where(:essence_type => "Alchemy::EssenceRichtext")
    scope :essence_selects, where(:essence_type => "Alchemy::EssenceSelect")
    scope :essence_booleans, where(:essence_type => "Alchemy::EssenceBoolean")

    class << self

      # Creates a new Content as descriped in the elements.yml file
      def create_from_scratch(element, essences_hash)
        # If no name given, we can create the content from essence type.
        # Used in picture gallery
        if essences_hash[:name].blank? && !essences_hash[:essence_type].blank?
          essences_of_same_type = element.contents.where(
            :essence_type => Content.normalize_essence_type(essences_hash[:essence_type])
          )
          description = {
            'type' => essences_hash[:essence_type],
            'name' => "#{essences_hash[:essence_type].classify.demodulize.underscore}_#{essences_of_same_type.count + 1}"
          }
        # Normal way to create
        else
          description = element.content_description_for(essences_hash[:name])
          description = element.available_content_description_for(essences_hash[:name]) if description.blank?
        end
        raise "No description found in elements.yml for #{essences_hash.inspect} and #{element.inspect}" if description.blank?
        content = new(:name => description['name'], :element_id => element.id)
        content.create_essence!(description)
        content
      end

      # Makes a copy of source and also copies the associated essence.
      #
      # You can pass a differences hash to update the attributes of the copy.
      #
      # === Example
      #
      #   @copy = Alchemy::Content.copy(@content, {:element_id => 3})
      #   @copy.element_id # => 3
      #
      def copy(source, differences = {})
        attributes = source.attributes.except(
          "position",
          "created_at",
          "updated_at",
          "creator_id",
          "updater_id",
          "id"
        ).merge(differences.stringify_keys)
        content = self.create!(attributes)
        new_essence = content.essence.class.new(content.essence.attributes.except(
          "id",
          "creator_id",
          "updater_id",
          "created_at",
          "updated_at"
        ))
        new_essence.save!
        raise "Essence not cloned" if new_essence.id == content.essence_id
        content.update_attributes(:essence_id => new_essence.id)
        content
      end

      # Returns the translated label for a content name.
      #
      # Translate it in your locale yml file:
      #
      #   alchemy:
      #     content_names:
      #      foo: Bar
      #
      # Optionally you can scope your content name to an element:
      #
      #   alchemy:
      #     content_names:
      #      article:
      #       foo: Baz
      #
      def translated_label_for(content_name, element_name = nil)
        Alchemy::I18n.t("content_names.#{element_name}.#{content_name}", :default => ["content_names.#{content_name}".to_sym, content_name.capitalize])
      end

      # Returns all content descriptions from elements.yml
      def descriptions
        @descriptions ||= Element.descriptions.collect { |e| e['contents'] }.flatten.compact
      end

      def normalize_essence_type(essence_type)
        essence_type = essence_type.classify
        if not essence_type.match(/^Alchemy::/)
          essence_type.gsub!(/^Essence/, 'Alchemy::Essence')
        else
          essence_type
        end
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

    # Returns my description hash from elements.yml
    # Returns the description from available_contents if my own description is blank
    def description
      if self.element.blank?
        logger.warn("\n+++++++++++ Warning: Content with id #{self.id} is missing its Element\n")
        return nil
      else
        @desc ||= self.element.content_description_for(self.name)
        if @desc.blank?
          @desc ||= self.element.available_content_description_for(self.name)
        else
          return @desc
        end
      end
    end

    # Gets the ingredient from essence
    def ingredient
      return nil if essence.nil?
      essence.ingredient
    end

    # Sets the ingredient from essence
    def ingredient=(value)
      raise "No essence found" if essence.nil?
      essence.ingredient = value
    end

    # Calls essence.update_attributes. Called from +Alchemy::Element#save_contents+
    # Ads errors to self.base if essence validation fails.
    def update_essence(params={})
      raise "Essence not found" if essence.nil?
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
      return false if description.blank?
      !description['validate'].blank?
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

    def essence_partial_name
      essence.partial_name
    end

    def normalized_essence_type
      self.class.normalize_essence_type(self.essence_type)
    end

    def has_custom_tinymce_config?
      !settings[:tinymce].nil?
    end

    def tinymce_class_name
      if has_custom_tinymce_config?
        if settings[:tinymce]
          "custom_tinymce #{name}"
        end
      else
        "default_tinymce"
      end
    end

    # Creates self.essence from description.
    def create_essence!(description)
      essence_class = self.class.normalize_essence_type(description['type']).constantize
      attributes = {
        :ingredient => default_or_lorem_ipsum(description['default'])
      }
      if description['type'] == "EssenceRichtext" || description['type'] == "EssenceText"
        attributes.merge!(:do_not_index => !description['do_not_index'].nil?)
      end
      essence = essence_class.create(attributes)
      if essence
        self.essence = essence
        save!
      else
        false
      end
    end

    def default_or_lorem_ipsum(default)
      return if default.nil?
      if default.is_a? Symbol
        I18n.t(default, :scope => :default_content_texts)
      else
        default
      end
    end

  end
end
