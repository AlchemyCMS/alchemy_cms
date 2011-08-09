if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function($) {
	
	var ElementEditorSelector = {};
	$.extend(Alchemy, ElementEditorSelector);
	
	Alchemy.ElementEditorSelector = {
		
		init : function() {
			var $elements = $('#element_area .element_editor');
			var self = Alchemy.ElementEditorSelector;
			self.reinit($elements);
		},
		
		reinit : function(elements) {
			var self = Alchemy.ElementEditorSelector;
			var $elements = $(elements);
			$elements.each(function () {
				self.bindEvent(this, $elements);
			});
			$elements.find('.element_head').click(self.onClickElement);
			$elements.find('.element_head').dblclick(function() {
				var id = $(this).parent().attr('id').replace(/\D/g,'');
				self.foldElement(id);
			});
		},
		
		onClickElement : function(e) {
			var self = Alchemy.ElementEditorSelector;
			var $element = $(this).parent('.element_editor');
			var id = $element.attr('id').replace(/\D/g,'');
			var $frame_elements, $selected_element;
			e.preventDefault();
			$('#element_area .element_editor').removeClass('selected');
			$element.addClass('selected');
			self.scrollToElement(this);
			$frame_elements = document.getElementById('alchemyPreviewWindow').contentWindow.jQuery('[data-alchemy-element]');
			$selected_element = $frame_elements.closest('[data-alchemy-element="'+id+'"]');
			$selected_element.trigger('Alchemy.SelectElement');
		},
		
		bindEvent : function (element) {
			var self = Alchemy.ElementEditorSelector;
			$(element).bind('Alchemy.SelectElementEditor', self.selectElement);
		},
		
		selectElement : function (e) {
			var self = Alchemy.ElementEditorSelector;
			var id = this.id.replace(/\D/g,'');
			var $element = $(this);
			var $elements = $('#element_area .element_editor');
			var $cells = $('#cells .sortable_cell');
			var $cell;
			e.preventDefault();
			$elements.removeClass('selected');
			$element.addClass('selected');
			if ($cells.size() > 0) {
				$cell = $element.parent('.sortable_cell');
				$('#cells').tabs('select', $cell.attr('id'));
			}
			if ($element.hasClass('folded')) {
				self.foldElement(id);
			} else {
				self.scrollToElement(this);
			}
		},
		
		scrollToElement : function(el) {
			$('#alchemyElementWindow').scrollTo(el, {duration: 400, offset: -10});
		},
		
		foldElement : function(id) {
			var self = Alchemy.ElementEditorSelector;
			$('#element_'+id+'_folder').hide();
			$('#element_'+id+'_folder_spinner').show();
			$.post('/admin/elements/fold?id='+id, function() {
				$('#element_'+id+'_folder').show();
				$('#element_'+id+'_folder_spinner').hide();
				self.scrollToElement('#element_'+id);
			});
		}
		
	}
	
})(jQuery);
