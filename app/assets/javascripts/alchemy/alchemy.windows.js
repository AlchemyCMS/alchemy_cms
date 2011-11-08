if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function ($) {

	$.extend(Alchemy, {

		getOverlaySpinner : function (options) {
			var defaults = {
				x: '47%',
				y: '33%'
			};
			var settings = $.extend({}, defaults, options);
			var $spinner = $('<img src="/assets/alchemy/ajax_loader.gif" />');
			var left = (settings.x - 32) / 2;
			var top = ((settings.y - 32) / 2) - 16;
			top = top < 0 ? 0 : top;
			$spinner.css({
				marginLeft: left + 'px',
				marginTop: top + 'px'
			});
			return $spinner;
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

		openPreviewWindow : function (url, title) {
			var $iframe = $('#alchemyPreviewWindow');
			if ($iframe.length === 0) {
				$iframe = $('<iframe src="'+url+'" id="alchemyPreviewWindow"></iframe>');
				$iframe.load(function() {
					$('#preview_load_info').hide();
				});
				$iframe.css({'background-color': '#ffffff'});
				Alchemy.PreviewWindow = $iframe.dialog({
					modal: false,
					title: title,
					width: $(window).width() - 504,
					height: $(window).height() - 90,
					minWidth: 600,
					minHeight: 300,
					show: "fade",
					hide: "fade",
					position: [70, 84],
					autoResize: true,
					closeOnEscape: false,
					create: function() {
						var $spinner = $('<img src="/assets/alchemy/ajax_loader.gif" alt="" id="preview_load_info" />');
						$('#ui-dialog-title-alchemyPreviewWindow').after($spinner);
						var $reload = $('<a href="#" class="ui-dialog-titlebar-refresh ui-corner-all" role="button"></a>');
						$reload.append('<span class="ui-icon ui-icon-refresh">reload</span>');
						$('#ui-dialog-title-alchemyPreviewWindow').after($reload);
						$reload.click(Alchemy.reloadPreview);
					},
					close: function(event, ui) { 
						Alchemy.PreviewWindowButton.enable();
					},
					open: function (event, ui) { 
						$(this).css({width: '100%'}); 
						Alchemy.PreviewWindowButton.disable();
						Alchemy.previewWindowFrameWidth = $('#alchemyPreviewWindow').width();
					}
				}).dialogExtend({
					"maximize" : true,
					"dblclick" : "maximize",
					"events" : {
						beforeMaximize: function(evt, dlg) {
							Alchemy.previewWindowPosition = $('#alchemyPreviewWindow').dialog('widget').offset();
							Alchemy.previewWindowFrameWidth = $('#alchemyPreviewWindow').width();
						},
						maximize : function(evt, dlg) {
							$('#alchemyPreviewWindow').css({width: "100%"});
						},
						restore : function(evt, dlg) {
							$('#alchemyPreviewWindow').dialog('widget').css(Alchemy.previewWindowPosition);
							$('#alchemyPreviewWindow').css({width: Alchemy.previewWindowFrameWidth});
						} 
					}
				});
			} else {
				$('#alchemyPreviewWindow').dialog('open');
			}
			Alchemy.PreviewWindow.refresh = function () {
				var $iframe = $('#alchemyPreviewWindow');
				$('#preview_load_info').show();
				$iframe.load(function() {
					$('#preview_load_info').hide();
				});
				$iframe.attr('src', $iframe.attr('src'));
				return true;
			};
		},

		PreviewWindowExists : function() {
		  if (Alchemy.PreviewWindow) {
				return true;
		  } else {
				return false;
			}
		},

		reloadPreview : function() {
			Alchemy.PreviewWindow.refresh();
		},

		ElementsWindowButton : {
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

		PreviewWindowButton : {
			enable: function() {
				$('div#show_preview_window').removeClass('disabled');
			},
			disable: function() {
				$('div#show_preview_window').addClass('disabled');
			},
			toggle: function() {
				$('div#show_preview_window').toggleClass('disabled');
			}
		},

		openElementsWindow : function (path, options) {
			var $dialog = $('<div style="display: none" id="alchemyElementWindow"></div>');
			var closeCallback = function() {
				$dialog.dialog("destroy");
				$('#alchemyElementWindow').remove();
				Alchemy.ElementsWindowButton.enable();
			};
			$dialog.html(Alchemy.getOverlaySpinner({x: 420, y: 300}));
			Alchemy.ElementsWindow = $dialog.dialog({
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
					$dialog.before(Alchemy.createElementWindowToolbar(options.toolbarButtons));
				},
				open: function(event, ui) {
					Alchemy.ElementsWindowButton.disable();
					$.ajax({
						url: path,
						success: function(data, textStatus, XMLHttpRequest) {
							$dialog.html(data);
							Alchemy.ButtonObserver('#alchemyElementWindow .button');
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

		createElementWindowToolbar : function(buttons) {
			var $toolbar = $('<div id="overlay_toolbar"></div>'), btn;
			for (i = 0; i < buttons.length; i++) {
				btn = buttons[i];
				$toolbar.append(
					Alchemy.createToolbarButton({
						buttonTitle: btn.title, 
						buttonLabel: btn.label, 
						iconClass: btn.iconClass,
						onClick: btn.onClick,
						buttonId: btn.buttonId
					})
				);
			}
			return $toolbar;
		},

		createToolbarButton : function(options) {
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
			$dialog.html(Alchemy.getOverlaySpinner({x: size_x, y: size_y}));

			Alchemy.CurrentWindow = $dialog.dialog({
				modal: modal, 
				minWidth: size_x, 
				minHeight: size_y > 68 ? size_y : 68,
				title: title,
				resizable: resizable,
				show: "fade",
				hide: "fade",
				open: function (event, ui) {
					$.ajax({
						url: action_url,
						success: function(data, textStatus, XMLHttpRequest) {
							$dialog.html(data);
							$dialog.css({overflow: overflow ? 'visible' : 'auto'});
							$dialog.dialog('widget').css({overflow: overflow ? 'visible' : 'hidden'});
							Alchemy.SelectBox('#alchemyOverlay select');
							Alchemy.ButtonObserver('#alchemyOverlay .button');
						},
						error: function(XMLHttpRequest, textStatus, errorThrown) {
							Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown);
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
						url: '/admin/trash?page_id=' + page_id,
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
				$.get('/admin/trash?page_id='+page_id, function(html) {
					$('#alchemyTrashWindow').html(html);
				});
			}
		}

	});
})(jQuery);
