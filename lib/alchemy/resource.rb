require 'active_support/inflector'

module Alchemy
  class Resource

    attr_accessor :skip_attributes

    DEFAULT_SKIPPED_ATTRIBUTES = %W[id updated_at created_at creator_id updater_id]

    def initialize(controller_path, module_definition=nil)
      @controller_path = controller_path
      @module_definition = module_definition
      self.skip_attributes = DEFAULT_SKIPPED_ATTRIBUTES
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
      self.model.columns.collect do |col|
        {:name => (human_relation_name(col.name) || col.name), :type => (human_relation_name(col.name) || col.type)} unless self.skip_attributes.include?(col.name)
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

    protected

    def controller_path_array
      @controller_path.split('/')
    end

    def namespace_diff
      controller_path_array - model_array
    end

    def human_relation_name(column_name)
      human_relation(column_name)[:attribute] if human_relation(column_name).present?
    end

    def human_relation_type(column_name)
      human_relation(column_name)[:type] if human_relation(column_name).present?
    end

    def human_relation(column_name)
      subnavigation = @module_definition['navigation']['sub_navigation']
      if subnavigation.present?
        subnavigation.each do |sub|
          return nil if sub['human_relations'].nil?
          sub['human_relations'].each_pair do |k,value|
            return {:attribute => value.first, :type => value.last} if k == column_name
          end
        end
      end
    end

  end
end