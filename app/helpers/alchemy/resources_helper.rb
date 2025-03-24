# frozen_string_literal: true

module Alchemy
  module ResourcesHelper
    include Alchemy::Admin::ResourceName

    # = Alchemy::ResourceHelper
    #
    # Used to DRY up resource like structures in Alchemy's admin backend in combination with Alchemy::Resource
    #
    # See Alchemy::Resource for examples how to initialize a resource_handler
    #

    def resource_window_size
      @resource_window_size ||= "480x#{100 + resource_handler.attributes.length * 40}"
    end

    def resource_instance_variable
      instance_variable_get(:"@#{resource_name}")
    end

    def resources_instance_variable
      instance_variable_get(:"@#{resources_name}")
    end

    def resource_url_proxy
      if resource_handler.in_engine?
        eval(resource_handler.engine_name) # rubocop:disable Security/Eval
      else
        main_app
      end
    end

    def resource_scope
      @_resource_scope ||= [resource_url_proxy].concat(resource_handler.namespace_for_scope)
    end

    def resources_path(resource_or_name = resource_handler.namespaced_resources_name, options = {})
      polymorphic_path (resource_scope + [resource_or_name]), options
    end

    def resource_path(resource = resource_handler.namespaced_resource_name, options = {})
      resources_path(resource, options)
    end

    def new_resource_path(options = {})
      new_polymorphic_path (resource_scope + [resource_handler.namespaced_resource_name]), options
    end

    def edit_resource_path(resource = nil, options = {})
      path_segments = resource_scope + [resource] || resource_array
      edit_polymorphic_path path_segments, options
    end

    def resource_model
      resource_handler.model
    end

    # Returns the value from resource attribute
    #
    # If the attribute has a relation, the related object's attribute value will be returned.
    #
    # The output will be truncated after 50 chars.
    # Pass another number to truncate then and pass false to disable this completely.
    #
    # @param [Alchemy::Resource] resource
    # @param [Hash] attribute
    # @option options [Hash] :truncate (50) The length of the value returned.
    # @option options [Hash] :datetime_format (alchemy.default) The format of timestamps.
    # @option options [Hash] :time_format (alchemy.time) The format of time values.
    #
    # @return [String]
    #
    def render_attribute(resource, attribute, options = {})
      attribute_value = resource.send(attribute[:name])
      if attribute[:relation]
        record = resource.send(attribute[:relation][:name])
        value = record.present? ? record.send(attribute[:relation][:attr_method]) : Alchemy.t(:not_found)
      elsif attribute_value && attribute[:type].to_s =~ /(date|time)/
        localization_format = if attribute[:type] == :datetime
          options[:datetime_format] || :"alchemy.default"
        elsif attribute[:type] == :date
          options[:date_format] || :"alchemy.default"
        else
          options[:time_format] || :"alchemy.time"
        end
        value = l(attribute_value, format: localization_format)
      elsif attribute[:type] == :boolean
        value = attribute_value ? '<alchemy-icon name="check"></alchemy-icon>'.html_safe : nil
      else
        value = attribute_value
      end

      options.reverse_merge!(truncate: 50)
      if options[:truncate]
        value.to_s.truncate(options.fetch(:truncate, 50))
      else
        value
      end
    end

    # Returns a options hash for simple_form input fields.
    def resource_attribute_field_options(attribute)
      options = {hint: resource_handler.help_text_for(attribute)}
      input_type = attribute[:type].to_s
      case input_type
      when "boolean"
        options
      when "date", "time", "datetime"
        options.merge(as: input_type)
      when "text"
        options.merge(as: "text", input_html: {rows: 4})
      else
        options.merge(as: "string")
      end
    end

    # Returns true if the resource contains any relations
    def contains_relations?
      resource_handler.resource_relations.present?
    end

    # Returns an array of all resource_relations names
    def resource_relations_names
      resource_handler.resource_relations.collect { |_k, v| v[:name].to_sym }
    end

    def resource_has_tags
      resource_model.respond_to?(:tag_counts) && resource_model.tag_counts.any?
    end
  end
end
