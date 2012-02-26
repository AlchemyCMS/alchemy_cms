if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function ($) {

	$.extend(Alchemy, {

		getOverlaySpinner : function (options) {
			var defaults = {
				x: '400',
				y: '300'
			};
			var settings = $.extend({}, defaults, options);
			var $spinner_container = $('<div class="spinner_container"/>').css({width: settings.x, height: settings.y});
			var $spinner = $('<img src="/assets/alchemy/ajax_loader.gif" />');
			$spinner_container.append($spinner);
			$spinner.css({
				position: 'absolute',
				width: 32,
				height: 32,
				left: '50%',
				top: '50%',
				marginLeft: '-16px',
				marginTop: '-16px'
			});
			return $spinner_container;
		},

		AjaxErrorHandler : function($dialog, status, textStatus, errorThrown) {
			var $div = $('<div class="with_padding" />');
			var $errorDiv = $('<div id="errorExplanation" />');
			$dialog.html($div);
			$div.append($errorDiv);
			if (status === 0) {
				$errorDiv.append('<h2>The server does not respond!</h2>');
				$errorDiv.append('<p>Please start server and try again.</p>');
			} else {
				$errorDiv.append('<h2>'+errorThrown+' ('+status+')</h2>');
				$errorDiv.append('<p>Please check log and try again.</p>');
			}
		},

		ToolbarButton : function(options) {
			var $btn = $('<div class="button_with_label"></div>'), $lnk;
			if (options.buttonId) $btn.attr({'id': options.buttonId});
			$lnk = $('<a title="'+options.buttonTitle+'" class="icon_button"></a>');
			$lnk.click(options.onClick);
			$lnk.append('<span class="icon '+options.iconClass+'"></span>');
			$btn.append($lnk);
			$btn.append('<br><label>'+options.buttonLabel+'</label>');
			return $btn;
		},

		openConfirmWindow : function (options) {
			var $confirmation = $('<div style="display:none" id="alchemyConfirmation"></div>');
			$confirmation.appendTo('body');
			$confirmation.html('<p>'+options.message+'</p>');
			Alchemy.ConfirmationWindow = $confirmation.dialog({
				resizable: false,
				minHeight: 100,
				minWidth: 300,
				modal: true,
				title: options.title,
				show: "fade",
				hide: "fade",
				buttons: [
					{
						text: options.cancelLabel,
						click: function() {
							$(this).dialog("close");
						}
					},
					{
						text: options.okLabel,
						click: function() {
							$(this).dialog("close");
							options.okCallback();
						}
					}
				],
				open: function () {
					Alchemy.ButtonObserver('#alchemyConfirmation .button');
				},
				close: function() {
					$('#alchemyConfirmation').remove();
				}
			});
		},

		confirmToDeleteWindow : function (url, title, message, okLabel, cancelLabel) {
			var $confirmation = $('<div style="display:none" id="alchemyConfirmation"></div>');
			$confirmation.appendTo('body');
			$confirmation.html('<p>'+message+'</p>');
			Alchemy.ConfirmationWindow = $confirmation.dialog({
				resizable: false,
				minHeight: 100,
				minWidth: 300,
				modal: true,
				title: title,
				show: "fade",
				hide: "fade",
				buttons: [
					{
						text: cancelLabel,
						click: function() {
							$(this).dialog("close");
						}
					},
					{
						text: okLabel,
						click: function() {
							$(this).dialog("close");
							$.ajax({
								url: url,
								type: 'DELETE'
							});
						}
					}
				],
				open: function () {
					Alchemy.ButtonObserver('#alchemyConfirmation .button');
				},
				close: function() {
					$('#alchemyConfirmation').remove();
				}
			});
		},

		openWindow : function (action_url, title, size_x, size_y, resizable, modal, overflow) {
			overflow == undefined ? overflow = false: overflow = overflow;
			if (size_x === 'fullscreen') {
				size_x = $(window).width() - 50;
				size_y = $(window).height() - 50;
			}
			var $dialog = $('<div style="display:none" id="alchemyOverlay"></div>');
			$dialog.appendTo('body');
			$dialog.html(Alchemy.getOverlaySpinner({x: size_x === 'auto' ? 400 : size_x, y: size_y === 'auto' ? 300 : size_y}));
			Alchemy.CurrentWindow = $dialog.dialog({
				modal: modal,
				minWidth: size_x === 'auto' ? 400 : size_x,
				minHeight: size_y === 'auto' ? 300 : size_y,
				title: title,
				resizable: resizable,
				show: "fade",
				hide: "fade",
				width: size_x,
				open: function (event, ui) {
					$.ajax({
						url: action_url,
						success: function(data, textStatus, XMLHttpRequest) {
							$dialog.html(data);
							$dialog.css({overflow: overflow ? 'visible' : 'auto'});
							$dialog.dialog('widget').css({overflow: overflow ? 'visible' : 'hidden'});
							if (size_x === 'auto') {
								$dialog.dialog('widget').css({
									left: (($(window).width() / 2) - ($dialog.width() / 2))
								});
							}
							if (size_y === 'auto') {
								$dialog.dialog('widget').css({
									top: ($(window).height() - $dialog.dialog('widget').height()) / 2
								});
							}
							Alchemy.SelectBox('#alchemyOverlay select');
							Alchemy.Datepicker('#alchemyOverlay input.date, #alchemyOverlay input[type="date"]');
							Alchemy.ButtonObserver('#alchemyOverlay .button');
						},
						error: function(XMLHttpRequest, textStatus, errorThrown) {
							Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown);
						},
						complete: function(jqXHR, textStatus) {
							Alchemy.enableButton('.button.disabled');
						}
					});
				},
				beforeClose: function() {
					$(".sb.open").triggerAll("close");
				},
				close: function () {
					$dialog.remove();
				}
			});
		},

		closeCurrentWindow : function() {
			if (Alchemy.CurrentWindow) {
				Alchemy.CurrentWindow.dialog('close');
				Alchemy.CurrentWindow = null;
			} else {
				$('#alchemyOverlay').dialog('close');
			}
			return true;
		},

		zoomImage : function(url, title, width, height) {
			var window_height = height;
			var window_width = width;
			var $doc_width = $(window).width();
			var $doc_height = $(window).height();
			if (width > $doc_width) {
				window_width = $doc_width - 50;
			}
			if (height > $doc_height) {
				window_height = $doc_height - 50;
			}
			var $dialog = $('<div style="display:none" id="alchemyOverlay"></div>');
			$dialog.appendTo('body');
			$dialog.html(Alchemy.getOverlaySpinner({x: width, y: height}));
			$dialog.dialog({
				modal: false, 
				minWidth: window_width < 320 ? 320 : window_width, 
				minHeight: window_height < 240 ? 240 : window_height,
				title: title,
				show: "fade",
				hide: "fade",
				open: function (event, ui) {
					$.ajax({
						url: url,
						success: function(data, textStatus, XMLHttpRequest) {
							$dialog.html(data);
						},
						error: function(XMLHttpRequest, textStatus, errorThrown) {
							Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown);
						}
					});
				},
				close: function () {
					$dialog.remove();
				}
			});
			return false;
		},

		openTrashWindow : function (page_id, title) {
			var size_x = 380, size_y = 270;
			if (size_x === 'fullscreen') {
				size_x = $(window).width() - 50;
				size_y = $(window).height() - 50;
			}
			var $dialog = $('<div style="display:none" id="alchemyTrashWindow"></div>');
			$dialog.appendTo('body');
			$dialog.html(Alchemy.getOverlaySpinner({x: size_x, y: size_y}));
			
			Alchemy.trashWindow = $dialog.dialog({
				modal: false,
				width: 380,
				minHeight: 450,
				maxHeight: $(window).height() - 50,
				title: title,
				resizable: false,
				show: "fade",
				hide: "fade",
				open: function (event, ui) {
					$.ajax({
						url: Alchemy.routes.admin_trash_path(page_id),
						success: function(data, textStatus, XMLHttpRequest) {
							$dialog.html(data);
							// Need this for DragnDrop elements into elements window.
							// Badly this is screwing up maxHeight option
							$dialog.css({overflow: 'visible'}).dialog('widget').css({overflow: 'visible'});
						},
						error: function(XMLHttpRequest, textStatus, errorThrown) {
							Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown);
						}
					});
				},
				close: function () {
					$dialog.remove();
				}
			});
		},
		
		refreshTrashWindow: function(page_id) {
			if ($('#alchemyTrashWindow').length > 0) {
				$('#alchemyTrashWindow').html(Alchemy.getOverlaySpinner({x: 380, y: 270}));
				$.get(Alchemy.routes.admin_trash_path(page_id), function(html) {
					$('#alchemyTrashWindow').html(html);
				});
			}
		}

	});
})(jQuery);
