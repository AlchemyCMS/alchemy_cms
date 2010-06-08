var AlchemyFrameSet = Class.create({
	
	initialize: function(element) {
		var defaults = {
			top: 44,
			left: 92,
			right: 8,
			preview_top_menu: 82
		};
		var options = Object.extend(defaults, arguments[1] || { });
		this.options = options;
		this.element = $(element);
		this.addObservers();
		this.updateSize();
		this.preview_frame = $('preview_frame');
	},
	
	addObservers: (function () {
		Event.observe(window, 'resize', function () {
			this.updateSize();
			if (this.preview_frame) {
				this.updateFrameSize();
			}
		}.bind(this));
	}),
	
	updateSize: function () {
		var view_height = document.viewport.getDimensions().height;
		var view_width = document.viewport.getDimensions().width;
		var height = view_height - this.options.top;
		var width = view_width - this.options.left - this.options.right;
		this.element.setStyle({
			width: width + 'px',
			height: height + 'px'
		});
		this.content_height = height;
		this.content_width = width;
	},
	
	updateFrameSize: function () {
		console.info('updating frame');
		var height = this.content_height - this.options.preview_top_menu;
		var width = this.content_width;
		console.info('height, width: ', height, width);
		this.preview_frame.setStyle({
			width: width + 'px',
			height: height + 'px'
		});
	}
	
});
