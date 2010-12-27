(function() {
	
	jQuery(document).ready(function() {
		AlResizeFrame();
	});
	
	jQuery(window).resize(function() {
		AlResizeFrame();
	});
	
	AlResizeFrame = function() {
		var options = {
			top: 90,
			left: 84,
			right: 0
		};
		var $mainFrame = jQuery('#main_content');
		var $topFrame = jQuery('#top_menu');
		var view_height = jQuery(window).height();
		var view_width = jQuery(window).width();
		var mainFrameHeight = view_height - options.top;
		var topFrameHeight = options.top;
		var width = view_width - options.left - options.right;
		if ($mainFrame.length > 0) {
			$mainFrame.css({
				width: width,
				height: mainFrameHeight
			});
		}
		if ($topFrame.length > 0) {
			$topFrame.css({
				width: width,
				height: topFrameHeight
			});
		}
	};
	
})();
