if (typeof(Alchemy) === 'undefined') {
	var Alchemy;
}

(function ($) {
	
	// Setting jQueryUIs global animation duration
	$.fx.speeds._default = 400;
	
	// The Alchemy JavaScript Object contains all Functions
	Alchemy = {
		
		ElementSelector : function() {
			
			var $elements = $('[data-alchemy-element]');
			var selected_style = {
				'outline-width'					: '2px',
				'outline-style'					: 'solid',
				'outline-color'					: '#DB694C',
				'outline-offset'				: '4px',
				'-moz-outline-radius'		: '4px',
				'outline-radius'				: '4px'
			};
			var hover_style = {
				'outline-width'					: '2px',
				'outline-style'					: 'solid',
				'outline-color'					: '#98BAD5',
				'outline-offset'				: '4px',
				'-moz-outline-radius'		: '4px',
				'outline-radius'				: '4px'
			};
			var reset_style = {
				outline: '0 none'
			};
			
			$elements.bind('mouseover', function(e) {
				$(this).attr('title', 'Klicken zum bearbeiten');
				if (!$(this).hasClass('selected'))
					$(this).css(hover_style);
			});
			
			$elements.bind('mouseout', function() {
				$(this).removeAttr('title');
				if (!$(this).hasClass('selected'))
					$(this).css(reset_style);
			});
			
			$elements.bind('Alchemy.SelectElement', function(e) {
				e.preventDefault();
				var offset = 20;
				var $element = $(this);
				var $selected = $elements.closest('[class="selected"');
				$elements.removeClass('selected');
				$elements.css(reset_style);
				$(this).addClass('selected');
				$(this).css(selected_style);
				$('html, body').animate({
					scrollTop: $element.offset().top - offset,
					scrollLeft: $element.offset().left - offset
				}, 400);
			});
			
			$elements.bind('click', function(e) {
				e.preventDefault();
				var target_id = $(this).attr('data-alchemy-element');
				var $element_editor = window.parent.jQuery('#element_area .element_editor').closest('[id="element_'+target_id+'"]');
				$element_editor.trigger('Alchemy.SelectElementEditor', target_id);
				var $elementsWindow = window.parent.jQuery('#alchemyElementWindow');
				if ($elementsWindow.dialog("isOpen")) {
					$elementsWindow.dialog('moveToTop');
				} else {
					$elementsWindow.dialog('open');
				}
				$(this).trigger('Alchemy.SelectElement');
			});
			
		},
		
		debug : function(e) {
			if (window['console']) {
				console.debug(e);
				console.trace();
			}
		}
		
	};
	
})(jQuery);
