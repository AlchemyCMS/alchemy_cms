function initAlchemyPreviewMode() {
	
	if (typeof(Alchemy) === 'undefined') {
		var Alchemy = {};
	}
	
	(function ($) {
		
		// Setting jQueryUIs global animation duration
		$.fx.speeds._default = 400;
		
		// The Alchemy JavaScript Object contains all Functions
		$.extend(Alchemy, {
			
			ElementSelector : {
				
				// defaults
				styles : {
					reset : { outline: '0 none' },
					hover : {
						'outline-width'					: '2px',
						'outline-style'					: 'solid',
						'outline-color'					: '#98BAD5',
						'outline-offset'				: '4px',
						'-moz-outline-radius'		: '4px',
						'outline-radius'				: '4px'
					},
					selected : {
						'outline-width'					: '2px',
						'outline-style'					: 'solid',
						'outline-color'					: '#DB694C',
						'outline-offset'				: '4px',
						'-moz-outline-radius'		: '4px',
						'outline-radius'				: '4px'
					},
				},
				
				scrollOffset : 20,
				
				init : function() {
					var self = Alchemy.ElementSelector;
					var $elements = $('[data-alchemy-element]');
					var styles = self.styles;
					$elements.bind('mouseover', function(e) {
						$(this).attr('title', 'Klicken zum bearbeiten');
						if (!$(this).hasClass('selected'))
							$(this).css(styles.hover);
					});
					$elements.bind('mouseout', function() {
						$(this).removeAttr('title');
						if (!$(this).hasClass('selected'))
							$(this).css(styles.reset);
					});
					$elements.bind('Alchemy.SelectElement', self.selectElement);
					$elements.bind('click', self.clickElement);
					self.$previewElements = $elements;
				},
				
				selectElement : function(e) {
					var $this = $(this);
					var self = Alchemy.ElementSelector;
					var $elements = self.$previewElements;
					var styles = self.styles;
					var offset = self.scrollOffset;
					e.preventDefault();
					$elements.removeClass('selected').css(styles.reset);
					$this.addClass('selected').css(styles.selected);
					$('html, body').animate({
						scrollTop: $this.offset().top - offset,
						scrollLeft: $this.offset().left - offset
					}, 400);
				},
				
				clickElement : function(e) {
					var $this = $(this);
					var parent$ = window.parent.jQuery;
					var target_id = $this.attr('data-alchemy-element');
					var $element_editor = parent$('#element_area .element_editor').closest('[id="element_'+target_id+'"]');
					var $elementsWindow = parent$('#alchemyElementWindow');
					e.preventDefault();
					$element_editor.trigger('Alchemy.SelectElementEditor', target_id);
					if ($elementsWindow.dialog("isOpen")) {
						$elementsWindow.dialog('moveToTop');
					} else {
						$elementsWindow.dialog('open');
					}
					$this.trigger('Alchemy.SelectElement');
				},
				
			},
			
		});
		
	})(jQuery);
	
	Alchemy.ElementSelector.init();
	
}

// Found on http://css-tricks.com/snippets/jquery/load-jquery-only-if-not-present/
// 
// Only do anything if jQuery isn't defined
// 

(function() {
	
	if (typeof(jQuery) === 'undefined') {
		
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
		
		getScript('/javascripts/alchemy/jquery.js', function() {
			if (typeof(jQuery) !== 'undefined') {
				if (thisPageUsingOtherJSLibrary) {
					jQuery.noConflict();
				}
				initAlchemyPreviewMode();
			}
		});
		
	} else {
		initAlchemyPreviewMode();
	};
	
})();
