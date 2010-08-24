var AlchemyElementSelector = Class.create({
	
	initialize: function() {
		var defaults = { };
		var options = Object.extend(defaults, arguments[0] || { });
		this.options = options;
		this.elements = $$('.alchemy_preview_element');
		this.observeElements();
	},
	
	observeElements: (function () {
		this.elements.each(function (el) {
			el.observe('mouseover', function (e) {
				var t = e.currentTarget;
				t.setStyle({
  			  outline: '2px solid #bba589'
  			});
			});
			el.observe('mouseout', function (e) {
				var t = e.currentTarget;
				t.setStyle({outline: 'none'});
			});
			el.observe('click', function (e) {
				var target = e.currentTarget;
				var t_id = target.id.replace(/\D/g,'');
				var editors = window.parent.$$('#element_area .element_editor');
				var cur_ed = editors.detect(function (ed) {
					var ed_id = ed.id.replace(/\D/g,'');
					return ed_id === t_id;
				});
				cur_ed.fire('alchemy:select_element', {element_id: t_id});
				target.scrollTo();
			});
		});
	})
	
});
