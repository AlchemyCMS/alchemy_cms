var AlchemyPreviewFrame = Class.create({
	
	initialize: function(element) {
		var defaults = {
			top_menu_size: 132
		};
		var options = Object.extend(defaults, arguments[1] || { });
		this.options = options;
		this.element = $(element);
		this.addObservers();
		this.updateSize();
	},
	
	addObservers: (function () {
		Event.observe(window, 'resize', function () {
			this.updateSize();
		}.bind(this));
	}),
	
	updateSize: function () {
		var view_height = document.viewport.getDimensions().height;
		var height = view_height - this.options.top_menu_size;
		this.element.setStyle({
			width: '100%',
			height: height + 'px'
		});
	}
	
});
