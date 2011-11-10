module Admin::PagesHelper

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
	jQuery(function($){
		if (typeof(Alchemy) !== 'object') { Alchemy = {}; };
		Alchemy.Tinymce = {
			init : function() {
				var init = { #{init} };
				init.script_url = '/assets/tiny_mce/tiny_mce.js';
				init.plugins = '#{Alchemy::Tinymce.plugins.join(',')}';
				init.language = '#{I18n.locale}';
				#{setup}
				$('textarea.tinymce').tinymce(init);
			},
			addEditor : function(dom_id) {
				tinyMCE.execCommand('mceAddControl', true, dom_id);
			}
		};
		Alchemy.Tinymce.init();
	});
</script>".html_safe
	end

end
