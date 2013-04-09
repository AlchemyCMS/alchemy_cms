require 'active_support/inflector'
require 'active_support/core_ext'

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
  # Usually you don't want your users to edit all attributes provided by a model. Hence some default attributes,
  # namely id, updated_at, created_at, creator_id and updater_id are not returned by Resource#attributes.
  #
  # If you want to skip a different set of attributes just define a skip_attributes class method in your model class
  # that returns an array of strings: %W[id, updated_at]
  #
  # == Resource relations
  #
  # Alchemy::Resource can take care of ActiveRecord relations. You will have to announce relations by defining a
  # resource_relations class method in your model class that returns a hash like this:
  #
  #     {
  #       :location_id => {:attr_method => "location#name", :attr_type => :string},
  #       :organizer_id => {:attr_method => "organizer#name", :attr_type => :string}
  #     }
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
  #     resource = Resource.new('/admin/tags', {"engine_name"=>"alchemy"}, ActsAsTaggableOn::Tag)
  #
  class Resource
    attr_accessor :skip_attributes, :resource_relations, :model_associations
    attr_reader :model

    DEFAULT_SKIPPED_ATTRIBUTES = %W[id updated_at created_at creator_id updater_id]
    DEFAULT_SKIPPED_ASSOCIATIONS = %w(creator updater)

    def initialize(controller_path, module_definition=nil, custom_model=nil)
      @controller_path = controller_path
      @module_definition = module_definition
      @model = (custom_model or guess_model_from_controller_path)
      self.skip_attributes = model.respond_to?(:skip_attributes) ? model.skip_attributes : DEFAULT_SKIPPED_ATTRIBUTES
      if model.respond_to?(:resource_relations)
        if not model.respond_to?(:reflect_on_all_associations)
          raise MissingActiveRecordAssociation
        end
        store_model_associations
        map_relations
      end
    end

    def resource_array
      @_resource_array ||= controller_path_array.reject { |el| el == 'admin' }
    end

    def resources_name
      @_resources_name ||= resource_array.last
    end

    def resource_name
      @_resource_name ||= resources_name.singularize
    end

    def model_name
      ActiveSupport::Deprecation.warn("model_name is deprecated. Please use resource_name instead!")
      resource_name
    end

    def namespaced_resource_name
      return @_namespaced_resource_name unless @_namespaced_resource_name.nil?
      resource_name_array = resource_array
      resource_name_array.delete(engine_name) if in_engine?
      @_namespaced_resource_name = resource_name_array.join('_').singularize
    end

    def namespaced_model_name
      ActiveSupport::Deprecation.warn("namespaced_model_name is deprecated. Please use namespaced_resource_name instead!")
      namespaced_resource_name
    end

    def permission_scope
      #(resource_namespaced? ? "#{resource_namespace.underscore}_admin_#{resources_name}" : "admin_#{resources_name}").to_sym
      @_permission = @controller_path.gsub('/', '_').to_sym
    end

    def namespace_for_scope
      namespace_array = namespace_diff
      namespace_array.delete(engine_name) if in_engine?
      namespace_array
    end

    def attributes
      @_attributes ||= self.model.columns.collect do |col|
        unless self.skip_attributes.include?(col.name)
          { :name => col.name, :type => resource_relation_type(col.name) || col.type, :relation => resource_relation(col.name) }.delete_if { |k, v | v.nil? }
        end
      end.compact
    end

    # Returns all columns that are searchable
    #
    # For now it only uses string type columns
    #
    def searchable_attributes
      self.attributes.select { |a| a[:type] == :string }
    end

    def in_engine?
      not self.engine_name.nil?
    end

    def engine_name
      @module_definition and @module_definition['engine_name']
    end

    # Returns a help text for resource's form
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
      ::I18n.translate!(attribute[:name], :scope => [:alchemy, :resource_help_texts, resource_name])
    rescue ::I18n::MissingTranslationData
      false
    end


  private

    def guess_model_from_controller_path
      resource_array.join('/').classify.constantize
    end

    def controller_path_array
      @controller_path.split('/')
    end

    def namespace_diff
      controller_path_array - resource_array
    end

    def resource_relation_type(column_name)
      resource_relation(column_name).try(:[], :attr_type)
    end

    def resource_relation(column_name)
      resource_relations[column_name.to_sym] if resource_relations
    end

    # Expands the resource_relations hash with matching activerecord associations data.
    def map_relations
      self.resource_relations = {}
      model.resource_relations.each do |name, options|
        name = name.to_s.gsub(/_id$/, '') # ensure that we don't have an id
        association = association_from_relation_name(name)
        foreign_key = association.options[:foreign_key] || "#{association.name}_id".to_sym
        if options[:attr_method].to_s =~ /#/
          ActiveSupport::Deprecation.warn('Old style :attr_method used in Alchemy::Ressource#resource_relations. Please remove the # and pass column name only.', caller[2..10])
          options[:attr_method] = options[:attr_method].split('#').last
        end
        self.resource_relations[foreign_key] = options.merge(:model_association => association, :name => name)
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
