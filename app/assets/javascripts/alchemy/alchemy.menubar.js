function loadAlchemyMenuBar(options) {

	if (typeof(Alchemy) === 'undefined') {
		Alchemy = {};
	}

	Alchemy.Menubar = {

		show: function() {
			var bar = Alchemy.Menubar.build();
			$('body').prepend(bar);
		},

		build: function() {
			var bar = $('<div id="alchemy_menubar"/>')
				.append('<ul/>');
			bar.find('ul')
				.append('<li><a href="'+options.route+'/admin">zu Alchemy</a></li>')
				.append('<li><a href="'+options.route+'/admin/pages/'+options.page_id+'/edit">Seite bearbeiten</a></li>')
				.append('<li><a href="'+options.route+'/admin/logout">abmelden</a></li>');
			return bar;
		}

	};

	if (typeof(jQuery) === 'undefined') {
		loadjQuery(Alchemy.Menubar.show);
	} else {
		Alchemy.Menubar.show();
	}

};

// Load jQuery, if it's not defined.
// Found on http://css-tricks.com/snippets/jquery/load-jquery-only-if-not-present/
function loadjQuery(callback) {		
	var thisPageUsingOtherJSLibrary = false;

	if (typeof($) === 'function') {
		thisPageUsingOtherJSLibrary = true;
	}

	function getScript(url, success) {
		var script = document.createElement('script');
		var head = document.getElementsByTagName('head')[0], done = false;
		script.src = url;
		// Attach handlers for all browsers
		script.onload = script.onreadystatechange = function() {
			if (!done && (!this.readyState || this.readyState === 'loaded' || this.readyState === 'complete')) {
				done = true;
				// callback function provided as param
				success();
				script.onload = script.onreadystatechange = null;
				head.removeChild(script);
			};
		};
		head.appendChild(script);
	};

	getScript('/assets/jquery.min.js', function() {
		if (typeof(jQuery) !== 'undefined') {
			if (thisPageUsingOtherJSLibrary) {
				jQuery.noConflict();
			}
			callback();
		}
	});
}
