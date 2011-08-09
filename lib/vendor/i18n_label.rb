# Took from https://github.com/iain/i18n_label
module ActionView
  module Helpers
    class InstanceTag
      def to_label_tag(text = nil, options = {})
        options = options.stringify_keys
        name_and_id = options.dup
        add_default_name_and_id(name_and_id)
        options.delete("index")
        options["for"] ||= name_and_id["id"]
        if text.blank?
          content = method_name.humanize
          if object.class.respond_to?(:human_attribute_name)
            content = object.class.human_attribute_name(method_name)
          end
        else
          content = text.to_s
        end
        label_tag(name_and_id["id"], content, options)
      end
    end
  end
end