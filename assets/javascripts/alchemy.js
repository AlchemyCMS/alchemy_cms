// Setting jQueryUIs global animation duration
jQuery.fx.speeds._default = 400;

// The Alchemy JavaScript Object contains all Functions
var Alchemy = {
	
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
			jQuery(element).css({overflow: 'hidden'});
			id = parseInt(id.replace(/^image_picture_/, ''));
			jQuery.ajax({url:'/admin/pictures/'+id, type: 'PUT', data: {name: value}});
			return false;
		};

		jQuery('#alchemy .rename').click(function () {
			jQuery(this).css({overflow: 'visible'});
		});

		jQuery('#alchemy .rename').inPlaceEdit({
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
		var settings = jQuery.extend({}, defaults, options);
		var $spinner = jQuery('<img src="/images/alchemy/ajax_loader.gif" />');
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
		var $iframe = jQuery('#alchemyPreviewWindow');
		if ($iframe.length === 0) {
			$iframe = jQuery('<iframe src="'+url+'" id="alchemyPreviewWindow"></iframe>');
			$iframe.load(function() {
				jQuery('#preview_load_info').hide();
			});
			$iframe.css({'background-color': '#ffffff'});
			Alchemy.PreviewWindow = $iframe.dialog({
				modal: false,
				title: title,
				width: jQuery(window).width() - 512,
				height: jQuery(window).height() - 94,
				minWidth: 600,
				minHeight: 300,
				show: "fade",
				hide: "fade",
				position: [73, 84],
				autoResize: true,
				closeOnEscape: false,
				create: function() {
					var $spinner = jQuery('<img src="/images/alchemy/ajax_loader.gif" alt="" id="preview_load_info" />');
					jQuery('#ui-dialog-title-alchemyPreviewWindow').after($spinner);
					var $reload = jQuery('<a href="#" class="ui-dialog-titlebar-refresh ui-corner-all" role="button"></a>')
					$reload.append('<span class="ui-icon ui-icon-refresh">reload</span>');
					jQuery('#ui-dialog-title-alchemyPreviewWindow').after($reload);
					$reload.click(Alchemy.reloadPreview);
				},
				close: function(event, ui) { 
					Alchemy.PreviewWindowButton.enable() 
				},
				open: function (event, ui) { 
					jQuery(this).css({width: '100%'}); 
					Alchemy.PreviewWindowButton.disable();
					Alchemy.previewWindowFrameWidth = jQuery('#alchemyPreviewWindow').width();
				}
			}).dialogExtend({
				"maximize" : true,
				"dblclick" : "maximize",
				"events" : {
					beforeMaximize: function(evt, dlg) {
						Alchemy.previewWindowPosition = jQuery('#alchemyPreviewWindow').dialog('widget').offset();
						Alchemy.previewWindowFrameWidth = jQuery('#alchemyPreviewWindow').width();
					},
					maximize : function(evt, dlg) {
						jQuery('#alchemyPreviewWindow').css({width: "100%"});
					},
					restore : function(evt, dlg) {
						jQuery('#alchemyPreviewWindow').dialog('widget').css(Alchemy.previewWindowPosition);
						jQuery('#alchemyPreviewWindow').css({width: Alchemy.previewWindowFrameWidth});
					} 
				}
			});
		} else {
			jQuery('#alchemyPreviewWindow').dialog('open');
		}
		Alchemy.PreviewWindow.refresh = function () {
			var $iframe = jQuery('#alchemyPreviewWindow');
			jQuery('#preview_load_info').show();
			$iframe.load(function() {
				jQuery('#preview_load_info').hide();
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
			jQuery('div#show_element_window').removeClass('disabled');
		},
		disable: function() {
			jQuery('div#show_element_window').addClass('disabled');
		},
		toggle: function() {
			jQuery('div#show_element_window').toggleClass('disabled');
		}
	},
	
	PreviewWindowButton : {
		enable: function() {
			jQuery('div#show_preview_window').removeClass('disabled');
		},
		disable: function() {
			jQuery('div#show_preview_window').addClass('disabled');
		},
		toggle: function() {
			jQuery('div#show_preview_window').toggleClass('disabled');
		}
	},
	
	openElementsWindow : function (path, title) {
		var $dialog = jQuery('#alchemyElementWindow');
		if ($dialog.length === 0) {
			$dialog = jQuery('<div style="display:none" id="alchemyElementWindow"></div>');
			$dialog.html(Alchemy.getOverlaySpinner({x: 420, y: 300}));
			Alchemy.ElementsWindow = $dialog.dialog({
				modal: false, 
				minWidth: 422, 
				minHeight: 300,
				height: jQuery(window).height() - 94,
				title: title,
				show: "fade",
				hide: "fade",
				position: [jQuery(window).width() - 432, 84],
				closeOnEscape: false,
				open: function(event, ui) {
					Alchemy.ElementsWindowButton.disable();
					jQuery.ajax({
						url: path,
						success: function(data, textStatus, XMLHttpRequest) {
							$dialog.html(data);
						},
						error: function(XMLHttpRequest, textStatus, errorThrown) {
							Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown);
						}
					});
				},
				close: function() {
					Alchemy.ElementsWindowButton.enable();
				}
			});
		} else {
			$dialog.dialog('open');
		}
	},
	
	openConfirmWindow : function (url, title, message, ok_lable, cancel_label) {
		var $confirmation = jQuery('<div style="display:none" id="alchemyConfirmation"></div>');
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
			buttons: {
				'Nein': function() {
					jQuery(this).dialog("close");
				},
				'Ja': function() {
					jQuery(this).dialog("close");
					jQuery.ajax({
						url: url,
						type: 'delete'
					});
				}
			}
		});
	},

	openWindow : function (action_url, title, size_x, size_y, resizable, modal, overflow) {
		overflow == undefined ? overflow = false: overflow = overflow;
		if (size_x === 'fullscreen') {
			size_x = jQuery(window).width() - 50;
			size_y = jQuery(window).height() - 50;
		}
		var $dialog = jQuery('<div style="display:none" id="alchemyOverlay"></div>');
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
				jQuery.ajax({
					url: action_url,
					success: function(data, textStatus, XMLHttpRequest) {
						$dialog.html(data);
						$dialog.css({overflow: overflow ? 'visible' : 'auto'});
						$dialog.dialog('widget').css({overflow: overflow ? 'visible' : 'hidden'});
						Alchemy.SelectBox('#alchemyOverlay select');
					},
					error: function(XMLHttpRequest, textStatus, errorThrown) {
						Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown);
					}
				});
			},
			close: function () {
				jQuery('ul.items').remove();
				$dialog.remove();
			}
		});		
	},
	
	closeCurrentWindow : function() {
		if (Alchemy.CurrentWindow) {
			Alchemy.CurrentWindow.dialog('close');
			Alchemy.CurrentWindow = null;
		} else {
			jQuery('#alchemyOverlay').dialog('close');
		}
		return true;
	},
	
	zoomImage : function(url, title, width, height) {
		var window_height = height;
		var window_width = width;
		var $doc_width = jQuery(window).width();
		var $doc_height = jQuery(window).height();
		if (width > $doc_width) {
			window_width = $doc_width - 50;
		}
		if (height > $doc_height) {
			window_height = $doc_height - 50;
		}
		var $dialog = jQuery('<div style="display:none" id="alchemyOverlay"></div>');
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
				jQuery.ajax({
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
		var height = jQuery(window).height() - 150;
		var $iframe = jQuery('<iframe src="http://www.gnu.org/licenses/gpl-3.0.txt"></iframe>');
		$iframe.dialog({
			bgiframe: true,
			title: 'GNU GPL License',
			width: 650,
			height: height,
			autoResize: true,
			close: function(event, ui) { jQuery(this).dialog('destroy'); },
			open: function (event, ui) { jQuery(this).css({width: '100%'}); }
		});
	},
	
	openLinkWindow : function (linked_element, width) {
		var $dialog = jQuery('<div style="display:none" id="alchemyLinkOverlay"></div>');

		$dialog.html(Alchemy.getOverlaySpinner({x: width}));

		Alchemy.CurrentLinkWindow = $dialog.dialog({
			modal: true, 
			minWidth: parseInt(width) < 600 ? 600 : parseInt(width), 
			minHeight: 450,
			title: 'Link setzen',
			show: "fade",
			hide: "fade",
			open: function (event, ui) {
				jQuery.ajax({
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
		var $overlay = jQuery('#overlay');
		$overlay.css("visibility", show ? 'visible': 'hidden');
	},
	
	toggleElement : function (id, url, token) {
		jQuery('#element_'+id+'_folder').hide();
		jQuery('#element_'+id+'_folder_spinner').show();
		jQuery.post(url, {
			authenticity_token: encodeURIComponent(token)
		}, function(request) {
			jQuery('#element_'+id+'_folder').show();
			jQuery('#element_'+id+'_folder_spinner').hide();
		});
		return false;
	},
	
	ListFilter : function(selector) {
		var text = jQuery('#search_field').val().toLowerCase();
		var $boxes = jQuery(selector);
		$boxes.map(function() {
			$this = jQuery(this);
			$this.css({
				display: $this.attr('name').toLowerCase().indexOf(text) != -1 ? '' : 'none'
			});
		});
	},
	
	selectPageForInternalLink : function(selected_element, urlname) {
		jQuery('#page_anchor').removeAttr('value');
		// We have to remove the Attribute. If not the value does not get updated.
		jQuery('.elements_for_page').hide();
		jQuery('#internal_urlname').val('/' + urlname);
		jQuery('#alchemyLinkOverlay #sitemap .selected_page').removeClass('selected_page');
		jQuery('#sitemap_sitename_' + selected_element).addClass('selected_page').attr('name', urlname);
	},
	
	createLink : function(link_type, url, title, extern) {
		var element = Alchemy.CurrentLinkWindow.linked_element;
		if (element.editor) {
			// aka we are linking text inside of TinyMCE
			var editor = element.editor;
			var l = editor.execCommand('mceInsertLink', false, {
				href: url,
				'class': link_type,
				title: title,
				target: (extern ? '_blank': null)
			});
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
			jQuery('#content_' + content_id + '_link').val(url);
			jQuery('#content_' + content_id + '_link_title').val(title);
			jQuery('#content_' + content_id + '_link_class_name').val(link_type);
			jQuery('#content_' + content_id + '_link_target').val(extern ? '1': '0');
		}
	},
	
	// Selects the tab for kind of link and fills all fields.
	selectLinkWindowTab : function() {
		var linked_element = Alchemy.CurrentLinkWindow.linked_element;
		var link;
		
		// Creating an temporary anchor node if we are linking an EssencePicture or EssenceText.
		if (linked_element.nodeType) {
			link = Alchemy.createTempLink(linked_element);
		}
		
		// Restoring the bookmarked selection inside the TinyMCE of an EssenceRichtext.
		else {
			link = linked_element.node;
			linked_element.selection.moveToBookmark(linked_element.bookmark);
		}
		
		jQuery('#alchemyLinkOverlay .link_title').val(link.title);
		jQuery('#alchemyLinkOverlay .link_target').attr('checked', link.target == "_blank");
		
		// Checking of what kind the link is (internal, external, file or contact_form).
		if (link.nodeName == "A") {
			var title = link.title == null ? "": link.title;

			// Handling an internal link.
			if ((link.className == '') || link.className == 'internal') {
				var internal_anchor = link.hash.split('#')[1];
				var internal_urlname = link.pathname;
				Alchemy.showLinkWindowTab('#overlay_tab_internal_link');
				jQuery('#internal_urlname').val(internal_urlname);
				var $sitemap_line = jQuery('.sitemap_sitename').closest('[name="'+internal_urlname+'"]');
				if ($sitemap_line.length > 0) {
					// Select the line where the link was detected in.
					$sitemap_line.addClass("selected_page");
					jQuery('#page_selector_container').scrollTo($sitemap_line.parents('li'), {duration: 400, offset: -10});
					// is there an anchor in the url? then request the element selector via ajax and select the correct value. yeah!
					if (internal_anchor) {
						var $select_container = $sitemap_line.parent().find('.elements_for_page');
						$select_container.show();
						jQuery.get("/admin/elements/?page_urlname=" + jQuery(internal_urlname.split('/')).last()[0] + '&internal_anchor=' + internal_anchor);
					}
				}
			}
			
			// Handling an external link.
			if (link.className == 'external') {
				Alchemy.showLinkWindowTab('#overlay_tab_external_link');				
				var protocols = [];
				jQuery('#url_protocol option').map(function() {
					protocols.push(jQuery(this).attr('value'));
				});
				jQuery(protocols).each(function(index, value) {
					if (link.href.beginsWith(value)) {
						jQuery('#external_url').val(link.href.replace(value, ""));
						jQuery('#url_protocol').val(value);
					}
				});
			}
			
			// Handling a file link.
			if (link.className == 'file') {
				Alchemy.showLinkWindowTab('#overlay_tab_file_link');
				jQuery('#public_filename').val(link.pathname + link.search);
			}
			
			// Handling a contactform link.
			if (link.className == 'contact') {
				var link_url = link.pathname;
				var link_params = link.search;
				var link_subject = link_params.split('&')[0];
				var link_mailto = link_params.split('&')[1];
				var link_body = link_params.split('&')[2];
				Alchemy.showLinkWindowTab('#overlay_tab_contactform_link');
				jQuery('#contactform_url').val(link_url);
				jQuery('#contactform_subject').val(unescape(link_subject.replace(/subject=/, '')).replace(/\?/, ''));
				jQuery('#contactform_body').val(unescape(link_body.replace(/body=/, '')).replace(/\?/, ''));
				jQuery('#contactform_mailto').val(link_mailto.replace(/mail_to=/, '').replace(/\?/, ''));
			}
		}
	},
	
	showElementsFromPageSelector: function(id) {
		jQuery('#elements_for_page_' + id + ' div.selectbox').remove();
		jQuery('#elements_for_page_' + id).show();
		jQuery('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10});
	},
	
	hideElementsFromPageSelector: function(id) {
		jQuery('#elements_for_page_' + id).hide();
		jQuery('#elements_for_page_' + id + ' div.selectbox').remove();
		jQuery('#page_anchor').removeAttr('value');
		jQuery('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10});
	},
	
	createTempLink : function(linked_element) {
		var $tmp_link = jQuery("<a></a>");
		var essence_type = jQuery(linked_element).attr('name').replace('essence_', '').split('_')[0];
		var content_id;
		switch (essence_type) {
			case "picture":
				content_id = jQuery(linked_element).attr('name').replace('essence_picture_', '');
			break;
			case "text":
				content_id = jQuery(linked_element).attr('name').replace('essence_text_', '');
			break;
		}
		$tmp_link.attr('href', jQuery('#content_' + content_id + '_link').val());
		$tmp_link.attr('title', jQuery('#content_' + content_id + '_link_title').val());
		if (jQuery('#content_' + content_id + '_link_target').val() == '1') {
			$tmp_link.attr('target', '_blank');
		}
		$tmp_link.addClass(jQuery('#content_' + content_id + '_link_class_name').val());
		return $tmp_link[0];
	},
	
	removePictureLink : function(content_id) {
		jQuery('#content_' + content_id + '_link').val('');
		jQuery('#content_' + content_id + '_link_title').val('');
		jQuery('#content_' + content_id + '_link_class_name').val('');
		jQuery('#content_' + content_id + '_link_target').val('');
		jQuery('#edit_link_' + content_id).removeClass('linked');
	},
	
	showLinkWindowTab : function(id) {
		jQuery('#overlay_tabs').tabs("select", id);
	},
	
	fadeImage : function(image, spinner_selector) {
		try {
			jQuery(spinner_selector).hide();
			jQuery(image).fadeIn(600);
		} catch(e) {
			Alchemy.debug(e);
		};
	},
	
	saveElement : function(form, element_id) {
		try {
			var $rtf_contents = jQuery('#element_'+element_id+' div.content_rtf_editor');
			var saveElementAjaxRequest = function (form, element_id) {
				jQuery.ajax({
					url: '/admin/elements/' + element_id,
					type: 'PUT',
					data: jQuery(form).serialize(),
					beforeSend: function(request) {
						jQuery('#element_'+element_id+'_save').hide();
						jQuery('#element_'+element_id+'_spinner').show();
					},
					complete: function(request) {
						jQuery('#element_'+element_id+'_save').show();
						jQuery('#element_'+element_id+'_spinner').hide();
					}
				});
			};

			if ($rtf_contents.size() > 0) {
				// collecting all rtf elements and fire the saveElementAjaxRequest after the last tinymce.save event!
				$rtf_contents.map(function() {
					var $rtf_content = jQuery(this);
					var $text_area = $rtf_content.children('textarea');
					var editor = tinyMCE.get($text_area.attr('id'));
					editor.save();
					if ($rtf_content.get(0) == $rtf_contents.last().get(0)) {
						editor.onSaveContent.add(function(ed, o) {
							// delaying the ajax call, so that tinymce has enough time to save the content.
							setTimeout(function(){saveElementAjaxRequest(form, element_id);}, 500);
						});
					}
					//removing the editor instance before adding it dynamically after saving
					$text_area.prev().show();
					tinyMCE.execCommand('mceRemoveControl', true, editor.editorId);
				});
			} else {
				saveElementAjaxRequest(form, element_id);
			}
			return false;
			
		} catch(e) {
			alert(e);
		}
	},
	
	PageSorter : function () {
		jQuery('ul#sitemap').nestedSortable({
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
		
		jQuery('#save_page_order').click(function(){
			var params = jQuery('ul#sitemap').nestedSortable('serialize');
			jQuery.post('/admin/pages/order', params);
		});
	},
	
	ResizeFrame : function() {
		var options = {
			top: 90,
			left: 65,
			right: 0
		};
		var $mainFrame = jQuery('#main_content');
		var $topFrame = jQuery('#top_menu');
		var view_height = jQuery(window).height();
		var view_width = jQuery(window).width();
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
		
		var $elements = jQuery('[data-alchemy-element]');
		var selected_style = {
			'outline-width'  				 : '2px',
			'outline-style'  				 : 'solid',
			'outline-color'  				 : '#DB694C',
			'outline-offset' 				 : '4px',
			'-moz-outline-radius' 	 : '4px',
			'outline-radius'				 : '4px'
		};
		var hover_style = {
			'outline-width'  			   : '2px',
			'outline-style'  			   : 'solid',
			'outline-color'  			   : '#98BAD5',
			'outline-offset' 				 : '4px',
			'-moz-outline-radius'		 : '4px',
			'outline-radius'			   : '4px'
		};
		var reset_style = {
			outline: '0 none'
		};
		
		$elements.bind('mouseover', function(e) {
			jQuery(this).attr('title', 'Klicken zum bearbeiten');
			if (!jQuery(this).hasClass('selected'))
				jQuery(this).css(hover_style);
		});
		
		$elements.bind('mouseout', function() {
			jQuery(this).removeAttr('title');
			if (!jQuery(this).hasClass('selected'))
				jQuery(this).css(reset_style);
		});
		
		$elements.bind('Alchemy.SelectElement', function(e) {
			e.preventDefault();
			var offset = 20;
			var $element = jQuery(this);
			var $selected = $elements.closest('[class="selected"');
			$elements.removeClass('selected');
			$elements.css(reset_style);
			jQuery(this).addClass('selected');
			jQuery(this).css(selected_style);
			jQuery('html, body').animate({
				scrollTop: $element.offset().top - offset,
				scrollLeft: $element.offset().left - offset
			}, 400);
		});
		
		$elements.bind('click', function(e) {
			e.preventDefault();
			var target_id = jQuery(this).data('alchemy-element');
			var $element_editor = window.parent.jQuery('#element_area .element_editor').closest('[id="element_'+target_id+'"]');
			$element_editor.trigger('Alchemy.SelectElementEditor', target_id);
			var $elementsWindow = window.parent.jQuery('#alchemyElementWindow');
			if ($elementsWindow.dialog("isOpen")) {
				$elementsWindow.dialog('moveToTop');
			} else {
				$elementsWindow.dialog('open');
			}
			jQuery(this).trigger('Alchemy.SelectElement');
		});
		
	},
	
	ElementEditorSelector : function() {
		var $elements = jQuery('#element_area .element_editor');
		
		$elements.bind('Alchemy.SelectElementEditor', function (e) {
			e.preventDefault();
			var id = this.id.replace(/\D/g,'');
			var $element = jQuery(this);
			var $selected = $elements.closest('[class="selected"');
			$elements.removeClass('selected');
			$element.addClass('selected');
			if ($element.hasClass('folded')) {
				jQuery.post('/admin/elements/fold?id='+id, function() {
					Alchemy.scrollToElementEditor('#element_'+id);
				});
			} else {
				Alchemy.scrollToElementEditor(this);
			}
		});
		
		jQuery('#element_area .element_editor .element_head').click(function(e) {
			e.preventDefault();
			var $element = jQuery(this).parent('.element_editor');
			var id = $element.attr('id').replace(/\D/g,'');
			var $selected = $elements.closest('[class="selected"');
			$elements.removeClass('selected');
			$element.addClass('selected');
			Alchemy.scrollToElementEditor(this);
			var $frame_elements = document.getElementById('alchemyPreviewWindow').contentWindow.jQuery('[data-alchemy-element]');
			var $selected_element = $frame_elements.closest('[data-alchemy-element="'+id+'"]');
			$selected_element.trigger('Alchemy.SelectElement');
		});
		
	},
	
	scrollToElementEditor: function(el) {
		jQuery('#alchemyElementWindow').scrollTo(el, {duration: 400, offset: -10});
	},
	
	SortableElements : function(form_token) {
		jQuery('#element_area').sortable({
			items: 'div.element_editor',
			handle: '.element_handle',
			axis: 'y',
			placeholder: 'droppable_element_placeholder',
			forcePlaceholderSize: true,
			opacity: 0.5,
			cursor: 'move',
			tolerance: 'pointer',
			update: function(event, ui) {
				var ids = jQuery.map(jQuery(event.target).children(), function(child) {
					return child.id.replace(/element_/, '');
				});
				jQuery(event.target).css("cursor", "progress");
				jQuery.ajax({
					url: '/admin/elements/order',
					type: 'POST',
					data: "authenticity_token=" + encodeURIComponent(form_token) + "&" + jQuery.param({element_ids: ids}),
					complete: function () {
						jQuery(event.target).css("cursor", "auto");
					}
				});
			},
			start: function (event, ui) {
				var item = ui.item[0];
				var $textareas = jQuery(item).find('textarea.tinymce');
				$textareas.each(function() {
					var editor = tinyMCE.get(this.id);
					editor.save();
					tinyMCE.execCommand(
						'mceRemoveControl',
						true,
						editor.editorId
					);
				});
			},
			stop: function (event, ui) {
				TinymceHammer.init();
			}
    });
	},
	
	SortableContents : function(token) {
		jQuery('#element_area .picture_gallery_images').sortable({
			items: 'div.dragable_picture',
			handle: 'div.picture_handle',
			placeholder: 'droppable_content_placeholder',
			opacity: 0.5,
			cursor: 'move',
			tolerance: 'pointer',
			containment: 'parent',
			update: function(event, ui) {
				var ids = jQuery.map(jQuery(event.target).children('div.dragable_picture'), function (child) {
					return child.id.replace(/picture_/, '');
				});
				jQuery(event.originalTarget).css("cursor", "progress");
				jQuery.ajax({
					url: '/admin/contents/order',
					type: 'POST',
					data: "authenticity_token=" + encodeURIComponent(token) + "&" + jQuery.param({content_ids: ids}),
					complete: function () {
						jQuery(event.originalTarget).css("cursor", "move");
					}
				});
			}
		});
	},
	
	Tooltips : function() {
		var xOffset = 10;
		var yOffset = 20;		
		jQuery(".tooltip").hover(function(e) {
			this.original_title = this.title;
			if (this.original_title == '') {
				this.tooltip_content = jQuery(this).next('.tooltip_content').html();
			} else {
				this.tooltip_content = this.original_title;
			}
			if (this.tooltip_content != null) {
				this.title = "";
				jQuery("body").append("<div id='tooltip'>"+ this.tooltip_content +"</div>");
				jQuery("#tooltip")
				.css("top",(e.pageY - xOffset) + "px")
				.css("left",(e.pageX + yOffset) + "px")
				.fadeIn(400);
			}
		},
		function() {
			this.title = this.original_title;
			jQuery("#tooltip").remove();
		});
		jQuery(".tooltip").mousemove(function(e) {
			jQuery("#tooltip")
			.css("top",(e.pageY - xOffset) + "px")
			.css("left",(e.pageX + yOffset) + "px");
		});
	},
	
	SelectBox : function(selector) {
		jQuery(selector).sb({animDuration: 0, fixedWidth: false});
	},
	
	Buttons : function(options) {
		jQuery("button, input:submit, a.button").button(options);
	},
	
	fadeNotices : function() {
		jQuery('#flash_notices div[class!="flash error"]').delay(5000).hide('drop', { direction: "up" }, 400, function() {
			jQuery(this).remove();
		});
		jQuery('#flash_notices div[class="flash error"]')
		.css({cursor: 'pointer'})
		.click(function() {
			jQuery(this).hide('drop', { direction: "up" }, 400, function() {
				jQuery(this).remove();
			});
		});
	},
	
	debug : function(e) {
		if (window['console']) {
			console.debug(e);
		}
	}
	
};

// Call all Alchemy "onload" scripts
jQuery(document).ready(function () {
	
	Alchemy.ResizeFrame();
	Alchemy.Tooltips();
	//TODO: Alchemy.Buttons({icons: ''});
	
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
