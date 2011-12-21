if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function($) {

	var PreviewWindow = {};
	$.extend(Alchemy, PreviewWindow);

	Alchemy.PreviewWindow = {

		init : function (url, title) {
			var $iframe = $('#alchemyPreviewWindow');
			if ($iframe.length === 0) {
				$iframe = $('<iframe src="'+url+'" id="alchemyPreviewWindow" frameborder="0"></iframe>');
				$iframe.load(function() {
					$('#preview_load_info').hide();
				});
				$iframe.css({'background-color': '#ffffff'});
				Alchemy.PreviewWindow.currentWindow = $iframe.dialog({
					modal: false,
					title: title,
					width: $(window).width() - 504,
					height: $(window).height() - 78,
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
						Alchemy.PreviewWindow.button.enable();
					},
					open: function (event, ui) { 
						$(this).css({width: '100%'}); 
						Alchemy.PreviewWindow.button.disable();
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
		},

		refresh : function() {
			var $iframe = $('#alchemyPreviewWindow');
			$('#preview_load_info').show();
			$iframe.load(function() {
				$('#preview_load_info').hide();
			});
			$iframe.attr('src', $iframe.attr('src'));
			return true;
		},

		button : {
			enable: function() {
				$('div#show_preview_window').removeClass('disabled');
			},
			disable: function() {
				$('div#show_preview_window').addClass('disabled');
			},
			toggle: function() {
				$('div#show_preview_window').toggleClass('disabled');
			}
		}

	};

	Alchemy.reloadPreview = function() {
		Alchemy.PreviewWindow.refresh();
	};

})(jQuery);
