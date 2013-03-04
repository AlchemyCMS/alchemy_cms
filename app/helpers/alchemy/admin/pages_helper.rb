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
        tinymce_javascript_string = "
        <script type='text/javascript'>
          jQuery(function($) {
            if (typeof(Alchemy) !== 'object') { Alchemy = {}; };
            Alchemy.Tinymce = {
              init : function(callback) {
                var init = { #{init} };
                var spinner = Alchemy.Spinner.small();
                $('.tinymce_container').prepend(spinner.spin().el);
                init.mode = 'specific_textareas';
                init.editor_selector = 'default_tinymce';
                init.plugins = '#{Alchemy::Tinymce.plugins.join(',')}';
                init.language = '#{::I18n.locale.to_s.split('-')[0].downcase }';
                init.init_instance_callback = function(inst) {
                  $('#' + inst.editorId).prev('.spinner').remove();
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
          });
        </script>"
        if Alchemy::Tinymce.custom_config_contents.any?
          (tinymce_javascript_string + custom_tinymce_javascript_tags).html_safe
        else
          tinymce_javascript_string.html_safe
        end
      end

      def custom_tinymce_javascript_tags
        custom_config_string = "
          <script type='text/javascript'>
            jQuery(function($) {
              Alchemy.Tinymce.customInits = [];"
        custom_config_contents = Alchemy::Tinymce.custom_config_contents
        content_names = custom_config_contents.collect{ |c| c['name'] }
        if content_names.uniq.length != content_names.length
          raise TinymceError, "Duplicated content names with tinymce setting in elements.yml found. Please rename these contents."
        end
        custom_config_contents.each do |content|
          next unless content['settings']['tinymce']
          config = Alchemy::Tinymce.init.merge(content['settings']['tinymce'].symbolize_keys)
          config = config.collect { |key, value| "#{key} : #{value.to_json}" }.join(', ')
          custom_config_string += "
              Alchemy.Tinymce.customInits.push(function(callback) {
                var init = { #{config} };
                init.mode = 'specific_textareas';
                init.editor_selector = /custom_tinymce #{Regexp.escape(content['name'])}/;
                init.plugins = '#{Alchemy::Tinymce.plugins.join(',')}';
                init.language = '#{::I18n.locale.to_s.split('-')[0].downcase }';
                init.init_instance_callback = function(inst) {
                  var $this = $('#' + inst.editorId);
                  var parent = $this.parents('.element_editor');
                  parent.find('.spinner').remove();
                  inst.onChange.add(function (ed, l) {
                    Alchemy.setElementDirty(parent);
                  });
                }
                tinymce.init(init);
              });"
        end
        custom_config_string += "
            });
          </script>"
        custom_config_string.html_safe
      end

      def preview_sizes_for_select
        options_for_select([
          'auto',
          [_t('240', :scope => 'preview_sizes'), 240],
          [_t('320', :scope => 'preview_sizes'), 320],
          [_t('480', :scope => 'preview_sizes'), 480],
          [_t('768', :scope => 'preview_sizes'), 768],
          [_t('1024', :scope => 'preview_sizes'), 1024],
          [_t('1280', :scope => 'preview_sizes'), 1280]
        ])
      end

      # Returns the translated explanation of the page´s status.
      #
      def combined_page_status(page)
        _t(page.status.to_a.map{ |k, v| "#{k}.#{v}" }.flatten, :scope => "page_states").delete_if(&:blank?).join("<br>").html_safe
      end

    end
  end
end
