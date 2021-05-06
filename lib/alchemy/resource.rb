# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "active_support/inflector"

module Alchemy
  # = Alchemy::Resource
  #
  # Used to DRY up resource like structures in Alchemy's admin backend.
  # So far Language, User and Tag already uses this.
  #
  # It provides convenience methods to create an admin interface without further knowledge about
  # the model and the controller (it's instantiated with controller_path at least and guesses the model accordingly)
  #
  # For examples how to use in controllers see Alchemy::ResourcesController or inherit from it directly.
  #
  # == Naming Conventions
  #
  # As Rails' form helpers, path helpers, etc. and declarative authorization rely on controller_path even if the model
  # class is named differently (or sits in another namespace) model and controller are handled separatly here.
  # Therefore "resource" always refers to the controller_path whereas "model" refers to the model class.
  #
  # == Skip attributes
  #
  # Usually you don't want your users to see and edit all attributes provided by a model. Hence some default attributes,
  # namely id, updated_at, created_at, creator_id and updater_id are not returned by Resource#attributes.
  #
  # If you want to skip a different set of attributes just define a +skipped_alchemy_resource_attributes+ class method in your model class
  # that returns an array of strings.
  #
  # === Example
  #
  #     def self.skipped_alchemy_resource_attributes
  #       %w(id updated_at secret_token remote_ip)
  #     end
  #
  # == Restrict attributes
  #
  # Beside skipping certain attributes you can also restrict them. Restricted attributes can not be edited by the user but still be seen in the index view.
  # No attributes are restricted by default.
  #
  # === Example
  #
  #     def self.restricted_alchemy_resource_attributes
  #       %w(synced_at remote_record_id)
  #     end
  #
  # == Searchable attributes
  #
  # By default all :text and :string based attributes are searchable in the admin interface.
  # You can overwrite this behaviour by providing a set of attribute names that should be searchable instead.
  #
  # === Example
  #
  #    def self.searchable_alchemy_resource_attributes
  #      %w(remote_record_id firstname lastname age)
  #    end
  #
  # == Resource relations
  #
  # Alchemy::Resource can take care of ActiveRecord relations.
  #
  # === BelongsTo Relations
  #
  # For belongs_to associations you will have to define a +alchemy_resource_relations+ class method in your model class:
  #
  #     def self.alchemy_resource_relations
  #       {
  #         location: {attr_method: 'name', attr_type: 'string'},
  #         organizer: {attr_method: 'name', attr_type: 'string'}
  #       }
  #     end
  #
  # With this knowledge Resource#attributes will return location#name and organizer#name instead of location_id
  # and organizer_id. Refer to Alchemy::ResourcesController for further details on usage.
  #
  # == Creation
  #
  # Resource needs a controller_path at least. Without other arguments it will guess the model name from it and assume
  # that the model doesn't live in an engine. Moreover model and controller has to follow Rails' naming convention:
  #
  #   Event -> EventsController
  #
  # It will also strip "admin" automatically, so this is also valid:
  #
  #   Event -> Admin::EventsController
  #
  # If your Resource and it's controllers are part of an engine you need to provide Alchemy's module_definition,
  # so resource can provide the correct url_proxy. If you don't declare it in Alchemy, you need at least provide the
  # following hash (i.e. if your engine is named EventEngine):
  #
  #     resource = Resource.new(controller_path, {"engine_name" => "event_engine"})
  #
  # If you don't want to stick with these conventions you can separate model and controller by providing
  # a model class (for example used by Alchemy's Tags admin interface):
  #
  #     resource = Resource.new('/admin/tags', {"engine_name"=>"alchemy"}, Gutentag::Tag)
  #
  class Resource
    attr_accessor :resource_relations, :model_associations
    attr_reader :model

    DEFAULT_SKIPPED_ATTRIBUTES = %w(id created_at creator_id)
    DEFAULT_SKIPPED_ASSOCIATIONS = %w(creator)
    SEARCHABLE_COLUMN_TYPES = [:string, :text]

    def initialize(controller_path, module_definition = nil, custom_model = nil)
      @controller_path = controller_path
      @module_definition = module_definition
      @model = (custom_model || guess_model_from_controller_path)
      if model.respond_to?(:alchemy_resource_relations)
        if !model.respond_to?(:reflect_on_all_associations)
          raise MissingActiveRecordAssociation
        end

        store_model_associations
        map_relations
      end
    end

    def resource_array
      @_resource_array ||= controller_path_array.reject { |el| el == "admin" }
    end

    def resources_name
      @_resources_name ||= resource_array.last
    end

    def resource_name
      @_resource_name ||= resources_name.singularize
    end

    def namespaced_resource_name
      @_namespaced_resource_name ||= begin
        namespaced_resources_name.to_s.singularize
      end.to_sym # Rails >= 6.0.3.7 needs symbols in polymorphic routes
    end

    def namespaced_resources_name
      @_namespaced_resources_name ||= begin
        resource_name_array = resource_array.dup
        resource_name_array.delete(engine_name) if in_engine?
        resource_name_array.join("_")
      end.to_sym # Rails >= 6.0.3.7 needs symbols in polymorphic routes
    end

    def namespace_for_scope
      namespace_array = namespace_diff
      namespace_array.delete(engine_name) if in_engine?
      namespace_array.map(&:to_sym) # Rails >= 6.0.3.7 needs symbols in polymorphic routes
    end

    # Returns an array of underscored association names
    #
    def model_association_names
      return unless model_associations

      model_associations.map do |assoc|
        assoc.name.to_sym
      end
    end

    def attributes
      @_attributes ||= model.columns.collect do |col|
        next if skipped_attributes.include?(col.name)

        {
          name: col.name,
          type: resource_column_type(col),
          relation: resource_relation(col.name),
        }.delete_if { |_k, v| v.nil? }
      end.compact
    end

    def sorted_attributes
      @_sorted_attributes ||= attributes.
        sort_by  { |attr| attr[:name] == "name" ? 0 : 1 }.
        sort_by! { |attr| attr[:type] == :boolean ? 1 : 0 }.
        sort_by! { |attr| attr[:name] == "updated_at" ? 1 : 0 }
    end

    def editable_attributes
      attributes.reject { |h| restricted_attributes.map(&:to_s).include?(h[:name].to_s) }
    end

    # Returns all attribute names that are searchable in the admin interface
    #
    def searchable_attribute_names
      if model.respond_to?(:searchable_alchemy_resource_attributes)
        model.searchable_alchemy_resource_attributes
      else
        attributes.select { |a| searchable_attribute?(a) }
          .concat(searchable_relation_attributes(attributes))
          .collect { |h| h[:name] }
      end
    end

    # Search field input name
    #
    # Joins all searchable attribute names into a Ransack compatible search query
    #
    def search_field_name
      searchable_attribute_names.join("_or_") + "_cont"
    end

    def in_engine?
      !engine_name.nil?
    end

    def engine_name
      @module_definition && @module_definition["engine_name"]
    end

    # Returns a help text for resource's form or nil if no help text is available
    #
    # === Example:
    #
    #   de:
    #     alchemy:
    #       resource_help_texts:
    #         my_resource_name:
    #           attribute_name: This is the fancy help text
    #
    def help_text_for(attribute)
      ::I18n.translate!(attribute[:name], scope: [:alchemy, :resource_help_texts, resource_name])
    rescue ::I18n::MissingTranslationData
      nil
    end

    # Return attributes that should be viewable but not editable.
    #
    def restricted_attributes
      if model.respond_to?(:restricted_alchemy_resource_attributes)
        model.restricted_alchemy_resource_attributes
      else
        []
      end
    end

    # Return attributes that should neither be viewable nor editable.
    #
    def skipped_attributes
      if model.respond_to?(:skipped_alchemy_resource_attributes)
        model.skipped_alchemy_resource_attributes
      else
        DEFAULT_SKIPPED_ATTRIBUTES
      end
    end

    private

    def searchable_attribute?(attribute)
      SEARCHABLE_COLUMN_TYPES.include?(attribute[:type].to_sym) && !attribute.key?(:relation)
    end

    def searchable_attribute_on_relation?(attribute)
      attribute.key?(:relation) &&
        SEARCHABLE_COLUMN_TYPES.include?(attribute[:relation][:attr_type].to_sym)
    end

    def searchable_relation_attributes(attrs)
      attrs.select { |a| searchable_attribute_on_relation?(a) }.map { |a| searchable_relation_attribute(a) }
    end

    def searchable_relation_attribute(attribute)
      {
        name: "#{attribute[:relation][:model_association].name}_#{attribute[:relation][:attr_method]}",
        type: attribute[:relation][:attr_type],
      }
    end

    def guess_model_from_controller_path
      resource_array.join("/").classify.constantize
    end

    def controller_path_array
      @controller_path.split("/")
    end

    def namespace_diff
      controller_path_array - resource_array
    end

    def resource_relation_type(column_name)
      resource_relation(column_name).try(:[], :attr_type)
    end

    def resource_column_type(col)
      resource_relation_type(col.name) || (col.try(:array) ? :array : col.type)
    end

    def resource_relation(column_name)
      resource_relations[column_name.to_sym] if resource_relations
    end

    # Expands the resource_relations hash with matching activerecord associations data.
    def map_relations
      self.resource_relations = {}
      model.alchemy_resource_relations.each do |name, options|
        name = name.to_s.gsub(/_id$/, "") # ensure that we don't have an id
        association = association_from_relation_name(name)
        foreign_key = association.options[:foreign_key] || "#{association.name}_id".to_sym
        resource_relations[foreign_key] = options.merge(model_association: association, name: name)
      end
    end

    # Stores all activerecord associations in model_associations attribute
    def store_model_associations
      self.model_associations = model.reflect_on_all_associations.delete_if { |a| DEFAULT_SKIPPED_ASSOCIATIONS.include?(a.name.to_s) }
    end

    # Returns activerecord association that has the given name
    def association_from_relation_name(name)
      model_associations.detect { |a| a.name == name.to_sym }
    end
  end
end
