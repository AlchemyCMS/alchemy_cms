if (typeof(Alchemy) === 'undefined') {
	var Alchemy;
}

(function ($) {
	
	// Setting jQueryUIs global animation duration
	$.fx.speeds._default = 400;
	
	// The Alchemy JavaScript Object contains all Functions
	Alchemy = {
		
		inPlaceEditor : function (options) {
			var defaults = {
				save_label: 'save', 
				cancel_label: 'cancel'
			};
			var settings = $.extend({}, defaults, options);
			var cancel_handler = function(element) {
				$(element).css({overflow: 'hidden'});
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
		
		AjaxErrorHandler : function(element, status, textStatus, errorThrown) {
			element.html('<h1>'+status+'</h1>');
			element.append('<p>'+textStatus+'</p>');
			element.append('<p>'+errorThrown+'</p>');
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

		openLinkWindow : function (linked_element, width) {
			var $dialog = $('<div style="display:none" id="alchemyLinkOverlay"></div>');

			$dialog.html(Alchemy.getOverlaySpinner({x: width}));

			Alchemy.CurrentLinkWindow = $dialog.dialog({
				modal: true, 
				minWidth: parseInt(width) < 600 ? 600 : parseInt(width), 
				minHeight: 450,
				title: 'Link setzen',
				show: "fade",
				hide: "fade",
				open: function (event, ui) {
					$.ajax({
						url: '/admin/pages/link',
						success: function(data, textStatus, XMLHttpRequest) {
							$dialog.html(data);
							Alchemy.SelectBox('#alchemyLinkOverlay select');
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

			Alchemy.CurrentLinkWindow.linked_element = linked_element;

			Alchemy.CurrentLinkWindow.close = function () {
				Alchemy.CurrentLinkWindow.dialog('close');
				return true;
			};

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

		selectPageForInternalLink : function(selected_element, urlname) {
			$('#page_anchor').removeAttr('value');
			// We have to remove the Attribute. If not the value does not get updated.
			$('.elements_for_page').hide();
			$('#internal_urlname').val('/' + urlname);
			$('#alchemyLinkOverlay #sitemap .selected_page').removeClass('selected_page');
			$('#sitemap_sitename_' + selected_element).addClass('selected_page').attr('name', urlname);
		},

		createLink : function(link_type, url, title, extern) {
			var element = Alchemy.CurrentLinkWindow.linked_element;
			Alchemy.setElementDirty($(element).parents('.element_editor'));
			if (element.editor) {
				// aka we are linking text inside of TinyMCE
				var editor = element.editor;
				editor.execCommand('mceInsertLink', false, {
					href: url,
					'class': link_type,
					title: title,
					target: (extern ? '_blank': null)
				});
				editor.selection.collapse();
			} else {
				// aka: we are linking an content
				var essence_type = element.name.replace('essence_', '').split('_')[0];
				var content_id = null;
				switch (essence_type) {
				case "picture":
					content_id = element.name.replace('essence_picture_', '');
					break;
				case "text":
					content_id = element.name.replace('content_text_', '');
					break;
				}
				$('#content_' + content_id + '_link').val(url);
				$('#content_' + content_id + '_link_title').val(title);
				$('#content_' + content_id + '_link_class_name').val(link_type);
				$('#content_' + content_id + '_link_target').val(extern ? '1': '0');
				$(element).addClass('linked');
			}
		},

		// Selects the tab for kind of link and fills all fields.
		selectLinkWindowTab : function() {
			var linked_element = Alchemy.CurrentLinkWindow.linked_element, link;

			// Creating an temporary anchor node if we are linking an EssencePicture or EssenceText.
			if (linked_element.nodeType) {
				link = Alchemy.createTempLink(linked_element);
			}

			// Restoring the bookmarked selection inside the TinyMCE of an EssenceRichtext.
			else {
				if (linked_element.node.nodeName === 'A') {
					link = linked_element.node;
					linked_element.selection.moveToBookmark(linked_element.bookmark);
				} else {
					return false;
				}
			}

			$('#alchemyLinkOverlay .link_title').val(link.title);
			$('#alchemyLinkOverlay .link_target').attr('checked', link.target == "_blank");

			// Checking of what kind the link is (internal, external, file or contact_form).
			if ($(link).is("a")) {
				var title = link.title == null ? "": link.title;

				// Handling an internal link.
				if ((link.className == '') || link.className == 'internal') {
					var internal_anchor = link.hash.split('#')[1];
					var internal_urlname = link.pathname;
					Alchemy.showLinkWindowTab('#overlay_tab_internal_link');
					$('#internal_urlname').val(internal_urlname);
					var $sitemap_line = $('.sitemap_sitename').closest('[name="'+internal_urlname+'"]');
					if ($sitemap_line.length > 0) {
						// Select the line where the link was detected in.
						$sitemap_line.addClass("selected_page");
						$('#page_selector_container').scrollTo($sitemap_line.parents('li'), {duration: 400, offset: -10});
						// is there an anchor in the url? then request the element selector via ajax and select the correct value. yeah!
						if (internal_anchor) {
							var $select_container = $sitemap_line.parent().find('.elements_for_page');
							$select_container.show();
							$.get("/admin/elements/?page_urlname=" + $(internal_urlname.split('/')).last()[0] + '&internal_anchor=' + internal_anchor);
						}
					}
				}

				// Handling an external link.
				if (link.className == 'external') {
					Alchemy.showLinkWindowTab('#overlay_tab_external_link');				
					var protocols = [];
					$('#url_protocol option').map(function() {
						protocols.push($(this).attr('value'));
					});
					$(protocols).each(function(index, value) {
						if (link.href.beginsWith(value)) {
							$('#external_url').val(link.href.replace(value, ""));
							$('#url_protocol').val(value);
						}
					});
				}

				// Handling a file link.
				if (link.className == 'file') {
					Alchemy.showLinkWindowTab('#overlay_tab_file_link');
					$('#public_filename').val(link.pathname + link.search);
				}

				// Handling a contactform link.
				if (link.className == 'contact') {
					var link_url = link.pathname;
					var link_params = link.search;
					var link_subject = link_params.split('&')[0];
					var link_mailto = link_params.split('&')[1];
					var link_body = link_params.split('&')[2];
					Alchemy.showLinkWindowTab('#overlay_tab_contactform_link');
					$('#contactform_url').val(link_url);
					$('#contactform_subject').val(unescape(link_subject.replace(/subject=/, '')).replace(/\?/, ''));
					$('#contactform_body').val(unescape(link_body.replace(/body=/, '')).replace(/\?/, ''));
					$('#contactform_mailto').val(link_mailto.replace(/mail_to=/, '').replace(/\?/, ''));
				}
			}
		},

		showElementsFromPageSelector: function(id) {
			$('#elements_for_page_' + id + ' div.selectbox').remove();
			$('#elements_for_page_' + id).show();
			$('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10});
		},

		hideElementsFromPageSelector: function(id) {
			$('#elements_for_page_' + id).hide();
			$('#elements_for_page_' + id + ' div.selectbox').remove();
			$('#page_anchor').removeAttr('value');
			$('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10});
		},

		createTempLink : function(linked_element) {
			var $tmp_link = $("<a></a>");
			var essence_type = $(linked_element).attr('name').replace('essence_', '').split('_')[0];
			var content_id;
			switch (essence_type) {
				case "picture":
					content_id = $(linked_element).attr('name').replace('essence_picture_', '');
				break;
				case "text":
					content_id = $(linked_element).attr('name').replace('essence_text_', '');
				break;
			}
			$tmp_link.attr('href', $('#content_' + content_id + '_link').val());
			$tmp_link.attr('title', $('#content_' + content_id + '_link_title').val());
			if ($('#content_' + content_id + '_link_target').val() == '1') {
				$tmp_link.attr('target', '_blank');
			}
			$tmp_link.addClass($('#content_' + content_id + '_link_class_name').val());
			return $tmp_link[0];
		},

		removePictureLink : function(content_id) {
			Alchemy.setElementDirty($('#essence_picture_' + content_id).parents('.element_editor'));
			$('#content_' + content_id + '_link').val('');
			$('#content_' + content_id + '_link_title').val('');
			$('#content_' + content_id + '_link_class_name').val('');
			$('#content_' + content_id + '_link_target').val('');
			$('#edit_link_' + content_id).removeClass('linked');
		},

		showLinkWindowTab : function(id) {
			$('#overlay_tabs').tabs("select", id);
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
		
		PageSorter : function () {
			$('ul#sitemap').nestedSortable({
				disableNesting: 'no-nest',
				forcePlaceholderSize: true,
				handle: 'span.handle',
				items: 'li',
				listType: 'ul',
				opacity: 0.5,
				placeholder: 'placeholder',
				tabSize: 16,
				tolerance: 'pointer',
				toleranceElement: '> div'
			});

			$('#save_page_order').click(function(){
				var params = $('ul#sitemap').nestedSortable('serialize');
				$.post('/admin/pages/order', params);
			});
		},

		ResizeFrame : function() {
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

		ElementSelector : function() {
			var $elements = $('[data-alchemy-element]'),
			selected_style = {
				'outline-width'  				 : '2px',
				'outline-style'  				 : 'solid',
				'outline-color'  				 : '#4b93db',
				'outline-offset' 				 : '4px',
				'-moz-outline-radius' 	 : '4px',
				'outline-radius'				 : '4px'
			},
			hover_style = {
				'outline-width'  			   : '2px',
				'outline-style'  			   : 'solid',
				'outline-color'  			   : '#98BAD5',
				'outline-offset' 				 : '4px',
				'-moz-outline-radius'		 : '4px',
				'outline-radius'			   : '4px'
			},
			reset_style = {
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
				var offset = 20, $element = $(this), $selected = $elements.closest('[class="selected"]');
				e.preventDefault();
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
				var	target_id = $(this).data('alchemy-element'),
						parent$ = window.parent.jQuery,
						$element_editor = parent$('#element_area .element_editor').closest('[id="element_'+target_id+'"]'),
						$elementsWindow = parent$('#alchemyElementWindow');
				e.preventDefault();
				$element_editor.trigger('Alchemy.SelectElementEditor', target_id);
				if ($elementsWindow.dialog("isOpen")) {
					$elementsWindow.dialog('moveToTop');
				} else {
					$elementsWindow.dialog('open');
				}
				$(this).trigger('Alchemy.SelectElement');
			});
		},
		
		ElementEditorSelector : function() {
			var $elements = $('#element_area .element_editor');
			
			$elements.each(function () {
				Alchemy.bindSelectElementEditor(this, $elements);
			});
			
			$('#element_area .element_editor .element_head').click(function(e) {
				var $element = $(this).parent('.element_editor'),
				id = $element.attr('id').replace(/\D/g,''),
				$selected = $elements.closest('[class="selected"'),
				$frame_elements = document.getElementById('alchemyPreviewWindow').contentWindow.jQuery('[data-alchemy-element]'),
				$selected_element = $frame_elements.closest('[data-alchemy-element="'+id+'"]');
				e.preventDefault();
				$elements.removeClass('selected');
				$element.addClass('selected');
				Alchemy.scrollToElementEditor(this);
				$selected_element.trigger('Alchemy.SelectElement');
			});
			
		},
		
		bindSelectElementEditor: function (element, $elements) {
			var $cells = $('#cells .sortable_cell'), $cell;
			if (typeof($elements) === 'undefined') {
				var $elements = $('#element_area .element_editor');
			}
			$(element).bind('Alchemy.SelectElementEditor', function (e) {
				var id = this.id.replace(/\D/g,''), 
					$element = $(this), 
					$selected = $elements.closest('[class="selected"');
					e.preventDefault();
				$elements.removeClass('selected');
				$element.addClass('selected');
				if ($cells.size() > 0) {
					$cell = $element.parent('.sortable_cell');
					$('#cells').tabs('select', $cell.attr('id'));
				}
				if ($element.hasClass('folded')) {
					$('#element_'+id+'_folder').hide();
					$('#element_'+id+'_folder_spinner').show();
					$.post('/admin/elements/fold?id='+id, function() {
						$('#element_'+id+'_folder').show();
						$('#element_'+id+'_folder_spinner').hide();
						Alchemy.scrollToElementEditor('#element_'+id);
					});
				} else {
					Alchemy.scrollToElementEditor(this);
				}
			});
		},
		
		scrollToElementEditor: function(el) {
			$('#alchemyElementWindow').scrollTo(el, {duration: 400, offset: -10});
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
				minWidth: size_x, 
				minHeight: size_y,
				title: title,
				resizable: true,
				show: "fade",
				hide: "fade",
				open: function (event, ui) {
					$.ajax({
						url: '/admin/trash?page_id=' + page_id,
						success: function(data, textStatus, XMLHttpRequest) {
							$dialog.html(data);
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
			$(selector).sb({animDuration: 0, fixedWidth: false});
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
			var	$element = $(element);
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
			$('#cells').tabs('select', '#cell_'+cell_name);
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
		
	};
	
})(jQuery);

// Call all Alchemy "onload" scripts
jQuery(document).ready(function () {
	
	Alchemy.ResizeFrame();
	Alchemy.Tooltips();
	Alchemy.ButtonObserver('#alchemy button.button');
	
	if (typeof(jQuery().sb) === 'function') {
		Alchemy.SelectBox('body#alchemy select');
	}
	
	if (jQuery('#flash_notices').length > 0) {
		Alchemy.fadeNotices();
	}
	
});

jQuery(window).resize(function() {
	Alchemy.ResizeFrame();
});

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
