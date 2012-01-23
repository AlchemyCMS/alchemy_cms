if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function($) {

	$.extend(Alchemy, {

		ButtonObserver: function (selector) {
			$(selector).click(function(event) {
				Alchemy.disableButton(this);
			});
		},

		disableButton: function (button) {
			var $button = $(button), $clone = $button.clone(), width = $button.outerWidth(), text = $button.text();
			$button.hide();
			$button.parent().append($clone);
			$clone.attr({disabled: true, href: 'javascript:void(0)'})
			.addClass('disabled cloned-button')
			.css({width: width})
			.html('<img src="/assets/alchemy/ajax_loader.gif" style="width: 16px; height: 16px">')
			.show();
			return true;
		},

		enableButton: function (button) {
			var $button = $(button);
			$button.show();
			$button.parent().find('.cloned-button').remove();
			return true;
		}

	});

})(jQuery);
