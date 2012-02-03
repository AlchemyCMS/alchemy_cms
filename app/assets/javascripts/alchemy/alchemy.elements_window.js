if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function($) {

	var ElementsWindow = {};
	$.extend(Alchemy, ElementsWindow);

	Alchemy.ElementsWindow = {

		init : function (path, options, callback) {
			var $dialog = $('<div style="display: none" id="alchemyElementWindow"></div>');
			var closeCallback = function() {
				$dialog.dialog("destroy");
				$('#alchemyElementWindow').remove();
				Alchemy.ElementsWindow.button.enable();
			};
			$dialog.html(Alchemy.getOverlaySpinner({x: 420, y: 300}));
			Alchemy.ElementsWindow.currentWindow = $dialog.dialog({
				modal: false, 
				minWidth: 422, 
				minHeight: 300,
				height: $(window).height() - 90,
				title: options.texts.title,
				show: "fade",
				hide: "fade",
				position: [$(window).width() - 428, 84],
				closeOnEscape: false,
				create: function() {
					$dialog.before(Alchemy.ElementsWindow.createToolbar(options.toolbarButtons));
				},
				open: function(event, ui) {
					Alchemy.ElementsWindow.button.disable();
					$.ajax({
						url: path,
						success: function(data, textStatus, XMLHttpRequest) {
							$dialog.html(data);
							Alchemy.ButtonObserver('#alchemyElementWindow .button');
							Alchemy.Datepicker('#alchemyElementWindow input.date, #alchemyElementWindow input[type="date"]');
							callback.call();
						},
						error: function(XMLHttpRequest, textStatus, errorThrown) {
							Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown);
						}
					});
				},
				beforeClose : function() {
					if (Alchemy.isPageDirty()) {
						Alchemy.openConfirmWindow({
							title: options.texts.dirtyTitle,
							message: options.texts.dirtyMessage,
							okLabel: options.texts.okLabel,
							cancelLabel: options.texts.cancelLabel,
							okCallback: closeCallback
						});
						return false;
					} else {
						return true;
					}
				},
				close: closeCallback
			});
		},

		button : {
			enable: function() {
				$('div#show_element_window').removeClass('disabled');
			},
			disable: function() {
				$('div#show_element_window').addClass('disabled');
			},
			toggle: function() {
				$('div#show_element_window').toggleClass('disabled');
			}
		},

		createToolbar : function(buttons) {
			var $toolbar = $('<div id="overlay_toolbar"></div>'), btn;
			for (i = 0; i < buttons.length; i++) {
				btn = buttons[i];
				$toolbar.append(
					Alchemy.ToolbarButton({
						buttonTitle: btn.title, 
						buttonLabel: btn.label, 
						iconClass: btn.iconClass,
						onClick: btn.onClick,
						buttonId: btn.buttonId
					})
				);
			}
			return $toolbar;
		}

	}

})(jQuery);
