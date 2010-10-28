var AlchemyFrameSet = Class.create({
	
	initialize: function() {
		var defaults = {
			top: 90,
			left: 84,
			right: 0
		};
		var options = Object.extend(defaults, arguments[0] || { });
		this.options = options;
		this.mainFrame = $('main_content');
		this.topFrame = $('top_menu');
		this.addObservers();
		this.resize();
	},
	
	addObservers: (function () {
		Event.observe(window, 'resize', function () {
			this.resize();
		}.bind(this));
	}),
	
	resize: function() {
		this.updateSize();
	},
	
	updateSize: function () {
		var view_height = document.viewport.getDimensions().height;
		var view_width = document.viewport.getDimensions().width;
		var mainFrameHeight = view_height - this.options.top;
		var topFrameHeight = this.options.top;
		var width = view_width - this.options.left - this.options.right;
		if (this.mainFrame) {
			this.mainFrame.setStyle({
				width: width + 'px',
				height: mainFrameHeight + 'px'
			});
		}
		if (this.topFrame) {
			this.topFrame.setStyle({
				width: width + 'px',
				height: topFrameHeight + 'px'
			});
		}
	}
	
});
