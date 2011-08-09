if (typeof(Alchemy) === 'undefined') {
	var Alchemy = {};
}

(function ($) {
	
	// Setting jQueryUIs global animation duration
	$.fx.speeds._default = 400;
	
	// The Alchemy JavaScript Object contains all Functions
	$.extend(Alchemy, {
		
		inPlaceEditor : function (options) {
			var defaults = {
				save_label: 'save', 
				cancel_label: 'cancel'
			};
			var settings = jQuery.extend({}, defaults, options);
			var cancel_handler = function(element) {
				jQuery(element).css({overflow: 'hidden'});
				return true;
			};
			var submit_handler = function(element, id, value) {
				$(element).css({overflow: 'hidden'});
				id = parseInt(id.replace(/^image_picture_/, ''));
				$.ajax({url:'/admin/pictures/'+id, type: 'PUT', data: {name: value}});
				return false;
			};
			
			$('#alchemy .rename').click(function () {
				$(this).css({overflow: 'visible'});
			});
			
			$('#alchemy .rename').inPlaceEdit({
				submit : submit_handler,
				cancel : cancel_handler,
				html : ' \
			          <div class="inplace-edit"> \
			            <input type="text" value="" class="thin_border field" /> \
			            <div class="buttons"> \
			              <input type="button" value="'+settings.save_label+'" class="save-button button" /> \
			              <input type="button" value="'+settings.cancel_label+'" class="cancel-button button" /> \
			            </div> \
			          </div>'
			});
			
		},
		
		getOverlaySpinner : function (options) {
			var defaults = {
				x: '47%',
				y: '33%'
			};
			var settings = $.extend({}, defaults, options);
			var $spinner = $('<img src="/images/alchemy/ajax_loader.gif" />');
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
					width: $(window).width() - 512,
					height: $(window).height() - 94,
					minWidth: 600,
					minHeight: 300,
					show: "fade",
					hide: "fade",
					position: [73, 84],
					autoResize: true,
					closeOnEscape: false,
					create: function() {
						var $spinner = $('<img src="/images/alchemy/ajax_loader.gif" alt="" id="preview_load_info" />');
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
				height: $(window).height() - 94,
				title: options.texts.title,
				show: "fade",
				hide: "fade",
				position: [$(window).width() - 432, 84],
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
							Alchemy.ButtonObserver('#alchemyElementWindow button.button');
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
		
		openLicencseWindow : function() {
			var height = $(window).height() - 150;
			var $iframe = $('<iframe src="http://www.gnu.org/licenses/gpl-3.0.txt"></iframe>');
			$iframe.dialog({
				bgiframe: true,
				title: 'GNU GPL License',
				width: 650,
				height: height,
				autoResize: true,
				close: function(event, ui) { $(this).dialog('destroy'); },
				open: function (event, ui) { $(this).css({width: '100%'}); }
			});
		},
		
		pleaseWaitOverlay : function(show) {
			if (typeof(show) == 'undefined') {
				show = true;
			}
			var $overlay = $('#overlay');
			$overlay.css("visibility", show ? 'visible': 'hidden');
		},
		
		toggleElement : function (id, url, token, text) {
			var toggle = function() {
				$('#element_'+id+'_folder').hide();
				$('#element_'+id+'_folder_spinner').show();
				$.post(url, {
					authenticity_token: encodeURIComponent(token)
				}, function(request) {
					$('#element_'+id+'_folder').show();
					$('#element_'+id+'_folder_spinner').hide();
				});
			}
			if (Alchemy.isPageDirty()) {
				Alchemy.openConfirmWindow({
					title: text.title,
					message: text.message,
					okLabel: text.okLabel,
					cancelLabel: text.cancelLabel,
					okCallback: toggle
				});
				return false;
			} else {
				toggle();
			}
		},
		
		ListFilter : function(selector) {
			var text = $('#search_field').val().toLowerCase();
			var $boxes = $(selector);
			$boxes.map(function() {
				$this = $(this);
				$this.css({
					display: $this.attr('name').toLowerCase().indexOf(text) != -1 ? '' : 'none'
				});
			});
		},
		
		fadeImage : function(image, spinner_selector) {
			try {
				$(spinner_selector).hide();
				$(image).fadeIn(600);
			} catch(e) {
				Alchemy.debug(e);
			};
		},
		
		saveElement : function(form) {
			var $rtf_contents = $(form).find('div.content_rtf_editor');
			if ($rtf_contents.size() > 0) {
				$rtf_contents.each(function() {
					var id = $(this).children('textarea.tinymce').attr('id');
					tinymce.get(id).save();
				});
			}
		},
		
		setElementSaved : function(selector) {
			var $element = $(selector);
			Alchemy.setElementClean(selector);
			Alchemy.enableButton(selector + ' button.button');
		},
		
		resizeFrame : function() {
			var options = {
				top: 90,
				left: 65,
				right: 0
			};
			var $mainFrame = $('#main_content');
			var $topFrame = $('#top_menu');
			var view_height = $(window).height();
			var view_width = $(window).width();
			var mainFrameHeight = view_height - options.top;
			var topFrameHeight = options.top;
			var width = view_width - options.left - options.right;
			if ($mainFrame.length > 0) {
				$mainFrame.css({
					width: width,
					height: mainFrameHeight
				});
			}
			if ($topFrame.length > 0) {
				$topFrame.css({
					width: width,
					height: topFrameHeight
				});
			}
		},
		
		SortableElements : function(page_id, form_token) {
			$('#element_area .sortable_cell').sortable({
				items: 'div.element_editor',
				handle: '.element_handle',
				axis: 'y',
				placeholder: 'droppable_element_placeholder',
				forcePlaceholderSize: true,
				dropOnEmpty: true,
				opacity: 0.5,
				cursor: 'move',
				tolerance: 'pointer',
				update: function(event, ui) {
					var ids = $.map($(event.target).children(), function(child) {
						return child.id.replace(/element_/, '');
					});
					// Is the trash window open?
					if ($('#alchemyTrashWindow').length > 0) {
						// updating the trash icon
						if ($('#trash_items div.element_editor').not('.dragged').length === 0) {
							$('#element_trash_button .icon').removeClass('full');
							$('#trash_empty_notice').show();
						}
					}
					$(event.target).css("cursor", "progress");
					$.ajax({
						url: '/admin/elements/order',
						type: 'POST',
						data: "page_id=" + page_id + "&authenticity_token=" + encodeURIComponent(form_token) + "&" + $.param({element_ids: ids}),
						complete: function () {
							$(event.target).css("cursor", "auto");
							Alchemy.refreshTrashWindow(page_id);
						}
					});
				},
				start: function(event, ui) {
					var $textareas = ui.item.find('textarea.tinymce');
					$textareas.each(function() {
						tinymce.get(this.id).remove();
					});
				},
				stop: function(event, ui) {
					var $textareas = ui.item.find('textarea.tinymce');
					$textareas.each(function() {
						TinymceHammer.addEditor(this.id);
					});
				}
			});
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
		},
		
		SortableContents : function(selector, token) {
			$(selector).sortable({
				items: 'div.dragable_picture',
				handle: 'div.picture_handle',
				placeholder: 'droppable_content_placeholder',
				opacity: 0.5,
				cursor: 'move',
				tolerance: 'pointer',
				containment: 'parent',
				update: function(event, ui) {
					var ids = $.map($(event.target).children('div.dragable_picture'), function (child) {
						return child.id.replace(/essence_picture_/, '');
					});
					$(event.originalTarget).css("cursor", "progress");
					$.ajax({
						url: '/admin/contents/order',
						type: 'POST',
						data: "authenticity_token=" + encodeURIComponent(token) + "&" + $.param({content_ids: ids}),
						complete: function () {
							$(event.originalTarget).css("cursor", "move");
						}
					});
				}
			});
		},
		
		Tooltips : function() {
			var xOffset = 10;
			var yOffset = 20;		
			$(".tooltip").hover(function(e) {
				this.original_title = this.title;
				if (this.original_title == '') {
					this.tooltip_content = $(this).next('.tooltip_content').html();
				} else {
					this.tooltip_content = this.original_title;
				}
				if (this.tooltip_content != null) {
					this.title = "";
					$("body").append("<div id='tooltip'>"+ this.tooltip_content +"</div>");
					$("#tooltip")
					.css("top",(e.pageY - xOffset) + "px")
					.css("left",(e.pageX + yOffset) + "px")
					.fadeIn(400);
				}
			},
			function() {
				this.title = this.original_title;
				$("#tooltip").remove();
			});
			$(".tooltip").mousemove(function(e) {
				$("#tooltip")
				.css("top",(e.pageY - xOffset) + "px")
				.css("left",(e.pageX + yOffset) + "px");
			});
		},
		
		SelectBox : function(selector) {
			$(selector).sb({animDuration: 0, fixedWidth: true});
		},
		
		Buttons : function(options) {
			$("button, input:submit, a.button").button(options);
		},
		
		fadeNotices : function() {
			$('#flash_notices div[class!="flash error"]').delay(5000).hide('drop', { direction: "up" }, 400, function() {
				$(this).remove();
			});
			$('#flash_notices div[class="flash error"]')
			.css({cursor: 'pointer'})
			.click(function() {
				$(this).hide('drop', { direction: "up" }, 400, function() {
					$(this).remove();
				});
			});
		},
		
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
			var	$element = $(element);
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
				}
			} else if ($(element).is('a')) {
				okcallback = function() {
					Alchemy.pleaseWaitOverlay();
					document.location = element.pathname;
				}
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
		},
		
		handleEssenceCheckbox: function (checkbox) {
			var $checkbox = $(checkbox);
			if (checkbox.checked) {
				$('#' + checkbox.id + '_hidden').remove();
			} else {
				$checkbox.after('<input type="hidden" value="0" name="'+checkbox.name+'" id="'+checkbox.id+'_hidden">');
			}
		},
		
		DraggableTrashItems: function (items_n_cells) {
			$("#trash_items div.draggable").each(function () {
				$(this).draggable({
					helper: 'clone',
					iframeFix: 'iframe#alchemyPreviewWindow',
					connectToSortable: '#cell_' + items_n_cells[this.id],
					start: function(event, ui) { 
						$(this).hide().addClass('dragged');
						ui.helper.css({width: '300px'});
					},
					stop: function() {
						$(this).show().removeClass('dragged');
					}
				});
			});
		},
		
		selectOrCreateCellTab: function (cell_name, label) {
			if ($('#cell_'+cell_name).size() === 0) {
				$('#cells').tabs('add', '#cell_'+cell_name, label);
				$('#cell_'+cell_name).addClass('sortable_cell');
			}
			$('#cells').tabs('select', 'cell_'+cell_name);
		},
		
		ButtonObserver: function (selector) {
			$(selector).click(function(event) {
				Alchemy.disableButton(this);
			});
		},
		
		disableButton: function (button) {
			var $button = $(button), $clone = $button.clone(), width = $button.outerWidth(), text = $button.text();
			$button.hide();
			$button.parent().append($clone);
			$clone.attr({disabled: true})
			.addClass('disabled cloned-button')
			.css({width: width})
			.html('<img src="/images/alchemy/ajax_loader.gif">')
			.show();
			return true;
		},
		
		enableButton: function (button) {
			var $button = $(button);
			$button.show();
			$button.parent().find('.cloned-button').remove();
			return true;
		},
		
		debug : function(e) {
			if (window['console']) {
				console.debug(e);
				console.trace();
			}
		}
		
	});
	
})(jQuery);

(function($) {
	
	// Call all Alchemy "onload" scripts
	$(document).ready(function () {
		Alchemy.resizeFrame();
		Alchemy.Tooltips();
		if (typeof(jQuery().sb) === 'function') {
			Alchemy.SelectBox('body#alchemy select');
		}
		if (jQuery('#flash_notices').length > 0) {
			Alchemy.fadeNotices();
		}
	});
	
	// Alchemy window resize listener
	$(window).resize(function() {
		Alchemy.resizeFrame();
	});
	
})(jQuery);

// Javascript extensions

String.prototype.beginsWith = function(t, i) {
	if (i==false) {
		return (t == this.substring(0, t.length));
	}
	else {
		return (t.toLowerCase() == this.substring(0, t.length).toLowerCase());
	}
};

String.prototype.endsWith = function(t, i) {
	if (i==false) {
		return (t == this.substring(this.length - t.length));
	} 
	else {
		return (t.toLowerCase() == this.substring(this.length - t.length).toLowerCase());
	}
};
