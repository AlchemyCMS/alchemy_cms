(function() {
	tinymce.PluginManager.requireLangPack('alchemy_link');

	tinymce.create('tinymce.plugins.alchemy_link', {
		init: function(ed, url) {
			ed.addButton('alchemy_link', {
				title: 'alchemy_link.link_button_title',
				label: '',
				'class': 'alchemy_link',
				onclick: function() {
					ed.focus();
					openLinkWindow({
						node: ed.selection.getNode(),
						bookmark: ed.selection.getBookmark(),
						selection: ed.selection,
						editor: ed
					},
					(ed.settings.alchemy_link_overlay_width || 408));
				}
			});
			ed.onNodeChange.add(function(ed, cm, n, co) {
				// Activates the link button when the caret is placed in a anchor element 
				cm.setActive('alchemy_link', n.nodeName == 'A');
				var DOM = tinymce.DOM;
				var p = DOM.getParent(n, 'A');
				var c = cm.get('alchemy_link');
				if (c) {
					if (!p || !p.name) {
						c.setDisabled(!p && co);
						c.setActive( !! p);
					}
				}
			});
		},

		createControl: function(n, cm) {
			return null;
		},

		getInfo: function() {
			return {
				longname: 'Link overlay plugin for Alchemy',
				author: 'Thomas von Deyen',
				authorurl: 'http://thomas.vondeyen.com',
				infourl: 'http://alchemy-app.com',
				version: "0.3"
			};
		}
	});

	tinymce.PluginManager.add('alchemy_link', tinymce.plugins.alchemy_link);
})();
