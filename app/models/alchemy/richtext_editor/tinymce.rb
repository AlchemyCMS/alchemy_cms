module Alchemy
  module RichtextEditor
    module Tinymce
      private

      def tinymce_editor
        content_tag("alchemy-tinymce", editor_text_area, tinymce_config)
      end

      def tinymce_config
        config = custom_tinymce_config
        config["readonly"] = true.to_json if !editable?
        config
      end

      def custom_tinymce_config
        ingredient.custom_tinymce_config.each_with_object({}) do |(k, v), obj|
          obj[k.to_s.dasherize] = v.to_json
        end
      end
    end
  end
end
