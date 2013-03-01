module Alchemy
  module ResourcesHelper

    def resource_window_size
      @resource_window_size ||= "420x#{100 + resource_handler.attributes.length * 40}"
    end

    def resource_instance_variable
      instance_variable_get("@#{resource_handler.model_name}")
    end

    def resources_instance_variable
      instance_variable_get("@#{resource_handler.resources_name}")
    end

    def resource_url_proxy
      if resource_handler.in_engine?
        eval(resource_handler.engine_name)
      else
        main_app
      end
    end

    def resource_scope
      @_resource_scope ||= [resource_url_proxy].concat(resource_handler.namespace_for_scope)
    end

    def resources_path(resource=resource_handler.model, options={})
      polymorphic_path (resource_scope + [resource]), options
    end

    def resource_path(resource=resource_handler.model, options={})
      resources_path(resource, options)
    end

    def new_resource_path(options={})
      new_polymorphic_path (resource_scope + [resource_handler.model]), options
    end

    def edit_resource_path(resource=nil, options={})
      edit_polymorphic_path (resource_scope+([resource] or model_array)), options
    end

    def resource_permission_scope
      resource_handler.permission_scope
    end

    def resource_model_name
      resource_handler.model_name
    end

    def resource_model
      resource_handler.model
    end

    def render_attribute(obj, attribute)
      attr_array = attribute.split('.')
      attr_array.each do |attr|
        obj = obj.send(attr) if obj
      end
      obj
    end

    def resource_help_text(attribute)
      if help_text = resource_handler.help_text_for(attribute)
        content_tag(:p, help_text, class: 'foot_note')
      end
    end

    # Renders the human model name with a count as h1 header
    def resources_header
      content_tag :h1, "#{resources_instance_variable.total_count} #{resource_model.model_name.human(:count => resources_instance_variable.total_count)}"
    end

  end
end
