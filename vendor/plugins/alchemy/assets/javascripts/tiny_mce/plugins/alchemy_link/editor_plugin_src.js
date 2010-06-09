(function() {
	tinymce.PluginManager.requireLangPack('wa_link');
	
	tinymce.create('tinymce.plugins.wa_link', {
		init : function(ed, url) {
			ed.addButton('wa_link', {
				title : 'wa_link.link_button_title',
				label : '',
				'class' : 'wa_link',
				onclick : function() {
					ed.focus();
					openLinkWindow(ed, (ed.settings.wa_link_overlay_width || 408));
				}
			});
			ed.addButton('wa_unlink', {
				title : 'wa_link.unlink_button_title',
				label : '',
				'class' : 'wa_unlink',
				onclick : function() {
					ed.focus();
					waUnLink(ed);
				}
			});
			ed.onNodeChange.add(function(ed, cm, n, co) {
				// Activates the link button when the caret is placed in a anchor element 
				cm.setActive('wa_link', n.nodeName == 'A');
				var DOM = tinymce.DOM;
				p = DOM.getParent(n, 'A');
				if (c = cm.get('wa_link')) {
					if (!p || !p.name) {
						c.setDisabled(!p && co);
						c.setActive(!!p);
					}
				}
				if (c = cm.get('wa_unlink')) {
					c.setDisabled(n.nodeName != 'A');
				}
			});
		},
		
		createControl : function(n, cm) {
					return null;
		},
		
		getInfo : function() {
			return {
				longname : 'Link overlay plugin for Alchemy',
				author : 'Thomas von Deyen',
				authorurl : 'http://thomas.vondeyen.com',
				infourl : 'http://alchemy.vondeyen.com',
				version : "0.2"
			};
		}
	});
	
	tinymce.PluginManager.add('wa_link', tinymce.plugins.wa_link);
})();
