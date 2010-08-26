var AlchemyElementEditorSelector = Class.create({
	
	initialize: function(element) {
		var defaults = { };
		var options = Object.extend(defaults, arguments[1] || { });
		this.options = options;
		this.element = $(element);
		this.startObserving();
	},
	
	startObserving: (function () {
		this.element.observe('alchemy:select_element', function (e) {
			var el_ed = e.element();
			var id = e.memo.element_id;
			var editors = $$('#element_area .element_editor');
			var current_selected = editors.detect(function (editor) {
				return editor.hasClassName('selected');
			});
			editors.each(function (ed) {
				ed.removeClassName('selected');
			});
			el_ed.addClassName('selected');
			if (el_ed.hasClassName('folded')) {
				new Ajax.Request(
					'/admin/elements/fold?id='+id,
					{
						request: 'post',
						onComplete: function () {
							$('element_<%= element.id %>').addClassName('selected');
							scrollToElement(id);
						}
					}
				);
			} else if (current_selected != el_ed) {
				scrollToElement(id);
			}
			e.stop();
		});
		var element_head = this.element.down('div.element_head');
		element_head.observe('click', function (e) {
			var target = e.currentTarget.up();
			var id = target.id.replace(/\D/g,'');
			var editors = $$('#element_area .element_editor');
			var current_selected = editors.detect(function (editor) {
				return editor.hasClassName('selected');
			});
			editors.each(function (ed) {
				ed.removeClassName('selected');
			});
			target.addClassName('selected');
			scrollToElement(id);
			var iframe = preview_window.getContent();
			var frame_win = iframe.contentWindow;
			var frame_els = frame_win.$$('.alchemy_preview_element');
			var selected_el = frame_els.detect(function (frame_el) {
				var el_id = frame_el.id.replace(/\D/g,'');
				return el_id == id;
			});
			frame_els.each(function (frame_el) {
				frame_el.setStyle({outline: 'none'});
			})
			selected_el.setStyle({
			  outline: '2px solid #bba589'
			});
			selected_el.scrollTo();
		});
	})
	
});
