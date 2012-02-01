if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function($) {

	$.extend(Alchemy, {

		ElementDirtyObserver : function(selector) {
			var $elements = $(selector);
			$elements.find('textarea.tinymce').map(function() {
				var $this = $(this);
				var ed = tinymce.get(this.id);
				ed.onChange.add(function(ed, l) {
					Alchemy.setElementDirty($this.parents('.element_editor'));
				});
			});
			$elements.find('input[type="text"]').bind('change', function() {
				$(this).addClass('dirty');
				Alchemy.setElementDirty($(this).parents('.element_editor'));
			});
			$elements.find('.element_foot input[type="checkbox"]').bind('click', function() {
				$(this).addClass('dirty');
				Alchemy.setElementDirty($(this).parents('.element_editor'));
			});
			$elements.find('select').bind('change', function() {
				$(this).addClass('dirty');
				Alchemy.setElementDirty($(this).parents('.element_editor'));
			});
		},

		setElementDirty : function(element) {
			var $element = $(element);
			$element.addClass('dirty');
			$element.find('.element_head .icon').addClass('element_dirty');
		},

		setElementClean : function(element) {
			var $element = $(element);
			$element.removeClass('dirty');
			$element.find('.element_foot input[type="checkbox"]').removeClass('dirty');
			$element.find('input[type="text"]').removeClass('dirty');
			$element.find('select').removeClass('dirty');
			$element.find('.element_head .icon').removeClass('element_dirty');
		},

		isPageDirty : function() {
			return $('#element_area').find('.element_editor.dirty').size() > 0;
		},

		checkPageDirtyness : function(element, text) {
			var okcallback;
			if ($(element).is('form')) {
				okcallback = function() {
					var $form = $('<form action="'+element.action+'" method="POST" style="display: none"></form>');
					$form.append($(element).find('input'));
					$form.appendTo('body');
					Alchemy.pleaseWaitOverlay();
					$form.submit();
				};
			} else if ($(element).is('a')) {
				okcallback = function() {
					Alchemy.pleaseWaitOverlay();
					document.location = element.pathname;
				};
			}
			if (Alchemy.isPageDirty()) {
				Alchemy.openConfirmWindow({
					title: text.title,
					message: text.message,
					okLabel: text.okLabel,
					cancelLabel: text.cancelLabel,
					okCallback: okcallback
				});
				return false;
			} else {
				return true;
			}
		},

		PageLeaveObserver : function(texts) {
			$('#main_navi a').click(function(event) {
				if (!Alchemy.checkPageDirtyness(event.currentTarget, texts)) {
					event.preventDefault();
				}
			});
		}

	});

})(jQuery);
