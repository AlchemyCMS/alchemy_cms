require 'active_support/inflector'
require 'active_support/core_ext'

module Alchemy
  class Resource

    attr_accessor :skip_attributes, :resource_relations

    DEFAULT_SKIPPED_ATTRIBUTES = %W[id updated_at created_at creator_id updater_id]

    def initialize(controller_path, module_definition=nil)
      @controller_path = controller_path
      @module_definition = module_definition
      self.skip_attributes = model.respond_to?(:skip_attributes) ? model.skip_attributes : DEFAULT_SKIPPED_ATTRIBUTES
      self.resource_relations = model.resource_relations if model.respond_to?(:resource_relations)
    end

    def model_array
      model_array = controller_path_array
      model_array.delete("admin")
      model_array
    end

    def model
      @_model ||= model_array.join('/').classify.constantize
    end

    def resources_name
      @_resources_name ||= model_array.last
    end

    def model_name
      @_model_name ||= resources_name.singularize
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
        {:name => (resource_relation_name(col.name) || col.name), :type => (resource_relation_type(col.name) || col.type)} unless self.skip_attributes.include?(col.name)
      end.compact
    end

    def searchable_attributes
      self.attributes.select { |a| a[:type] == :string }
    end

    def namespaced_model_name
      return @_namespaced_model_name unless @_namespaced_model_name.nil?
      model_name_array = self.model_array
      model_name_array.delete(self.engine_name) if in_engine?
      @_namespaced_model_name = model_name_array.join('_').singularize
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
    #         my_resource_model_name:
    #           attribute_name: This is the fancy help text
    #
    def help_text_for(attribute)
      ::I18n.translate!(attribute[:name], :scope => [:alchemy, :resource_help_texts, model_name])
    rescue ::I18n::MissingTranslationData
      false
    end

  protected

    def controller_path_array
      @controller_path.split('/')
    end

    def namespace_diff
      controller_path_array - model_array
    end

    def resource_relation_name(column_name)
      resource_relation(column_name).try(:[], :attr_method)
    end

    def resource_relation_type(column_name)
      resource_relation(column_name).try(:[], :attr_type)
    end

    def resource_relation(column_name)
      resource_relations[column_name.to_sym] if resource_relations
    end

  end
end
