if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function($) {

	var PageSorter = {};
	$.extend(Alchemy, PageSorter);

	Alchemy.PageSorter = {

		init : function () {
			$('ul#sitemap').nestedSortable({
				disableNesting: 'no-nest',
				forcePlaceholderSize: true,
				handle: 'span.handle',
				items: 'li',
				listType: 'ul',
				opacity: 0.5,
				placeholder: 'placeholder',
				tabSize: 16,
				tolerance: 'pointer',
				toleranceElement: '> div'
			});
			$('#save_page_order').click(function(e){
				Alchemy.pleaseWaitOverlay();
				e.preventDefault();
				var params = {
					set: JSON.stringify($('ul#sitemap').nestedSortable('toHierarchy'))
				};
				$.post(Alchemy.routes.order_admin_pages_path, params);
				return false;
			});
			$('#bottom_buttons .button').click(Alchemy.pleaseWaitOverlay);
			Alchemy.PageSorter.disableButton();
			Alchemy.resizeFrame();
		},

		disableButton : function() {
			var $buttonLink = $('#page_sorting_button a');
			$buttonLink.removeAttr('onclick');
			$('#page_sorting_button').addClass('active');
			$buttonLink.css({cursor: 'default'});
		}

	}

})(jQuery);
