module Alchemy
  module Admin
    module PagesHelper

      def tinymce_javascript_tags
        init = Alchemy::Tinymce.init
        if init.is_a?(Hash)
          init = HashWithIndifferentAccess.new(init)
          init = init.keys.sort.collect(&:to_s).sort.collect do |key|
            [key, init[key]]
          end
        end
        init = init.collect { |key, value| "#{key} : #{value.to_json}" }.join(', ')

        setup = "init.setup = #{Alchemy::Tinymce.setup};" if Alchemy::Tinymce.setup
        return "
    <script type='text/javascript'>
      jQuery(function(){
        if (typeof(Alchemy) !== 'object') { Alchemy = {}; };
        Alchemy.Tinymce = {
          init : function(callback) {
            var init = { #{init} };
            init.mode = 'specific_textareas';
            init.editor_selector = 'tinymce';
            init.plugins = '#{Alchemy::Tinymce.plugins.join(',')}';
            init.language = '#{::I18n.locale}';
            init.init_instance_callback = function(inst) {
              jQuery('#' + inst.editorId).prev('.essence_richtext_loader').hide();
            }
            if (callback)
              init.oninit = callback;
            #{setup}
            tinymce.init(init);
          },
          addEditor : function(dom_id) {
            tinymce.execCommand('mceAddControl', true, dom_id);
          }
        };
        Alchemy.Tinymce.init();
      });
    </script>".html_safe
      end

    end
  end
end
