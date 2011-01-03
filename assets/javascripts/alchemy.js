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
			id = parseInt(id.gsub(/^[image_picture_]/, ''));
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
		var $iframe = jQuery('<iframe src="'+url+'" id="alchemyPreviewWindow"></iframe>');

		Alchemy.PreviewWindow = $iframe.dialog({
			modal: false, 
	    title: title,
	    width: jQuery(window).width() - 534,
	    height: jQuery(window).height() - 98,
	    minWidth: 600,
	    minHeight: 300,
			show: "fade",
			hide: "fade",
			position: [92, 92],
			autoResize: true,
			closeOnEscape: false,
			close: function(event, ui) { jQuery(this).dialog('destroy'); },
			open: function (event, ui) { jQuery(this).css({width: '100%'}); }
		});

		Alchemy.PreviewWindow.refresh = function () {
			var $iframe = jQuery('#alchemyPreviewWindow');
			$iframe.attr('src', $iframe.attr('src'));
			return true;
		};

	},

	reloadPreview : function() {
		Alchemy.PreviewWindow.refresh();
	},

	openElementsWindow : function (path, title) {
		var $dialog = jQuery('<div style="display:none" id="alchemyOverlay"></div>');
		$dialog.html(Alchemy.getOverlaySpinner({x: 424, y: 300}));
		Alchemy.ElementsWindow = $dialog.dialog({
			modal: false, 
			minWidth: 424, 
			minHeight: 300,
			height: jQuery(window).height() - 98,
			title: title,
			show: "fade",
			hide: "fade",
			position: [jQuery(window).width() - 418, 92],
			closeOnEscape: false,
			open: function (event, ui) {
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
			close: function () {
				$dialog.remove();
			}
		});
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
						jQuery('#alchemyOverlay select').sb({animDuration: 0});
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

		Alchemy.CurrentWindow.close = function () {
			Alchemy.CurrentWindow.dialog('close');
			return true;
		};

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
			open: function (event, ui) { jQuery(this).css({width: 636}); }
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
	
	// Selects the tab for kind of link and fills all fields.
	selectLinkWindowTab : function() {
		var linked_element = Alchemy.CurrentLinkWindow.linked_element;
		var link = null;
		
		// Creating an temporary anchor node if we are linking an EssencePicture or EssenceText.
		if (linked_element.nodeType) {
			link = Alchemy.createTempLink(linked_element);
		}
		
		// Restoring the bookmarked selection inside the TinyMCE of an EssenceRichtext.
		else {
			link = linked_element.node;
			linked_element.selection.moveToBookmark(linked_element.bookmark);
		}
		
		// Checking of what kind the link is (internal, external, file or contact_form).
		if (link.nodeName == "A") {
			var title = link.title == null ? "": link.title;

			// Handling an internal link.
			if ((link.className == '') || link.className == 'internal') {
				var internal_anchor = link.hash.split('#')[1];
				var internal_urlname = link.pathname;
				Alchemy.showLinkWindowTab('#overlay_tab_internal_link');
				jQuery('#internal_link_title').val(title);
				jQuery('#internal_urlname').val(internal_urlname);
				jQuery('#internal_link_target').checked = (link.target == "_blank");
				var sitemap_line = jQuery('.sitemap_sitename').detect(function(f) {
					return internal_urlname == f.readAttribute('name');
				});
				if (sitemap_line) {
					// Select the line where the link was detected in.
					sitemap_line.addClassName("selected_page");
					page_select_scrollbar.scrollTo(sitemap_line.up('li'));
					// is there an anchor in the url? then request the element selector via ajax and select the correct value. yeah!
					if (internal_anchor) {
						var select_container = jQuery(sitemap_line).adjacent('.elements_for_page').first();
						select_container.show();
						jQuery.get(
							"/admin/elements/?page_urlname=" + internal_urlname.split('/').last(),
							function() {
								var alchemy_selectbox = select_container.children('.alchemy_selectbox');
								jQuery('#page_anchor').val('#' + internal_anchor);
							}
						);
					}
				}
			}
			
			// Handling an external link.
			if (link.className == 'external') {
				Alchemy.showLinkWindowTab('#overlay_tab_external_link');				
				var protocols = [];
				jQuery('#url_protocol_select .alchemy_selectbox_body a').map(function() {
					protocols.push(jQuery(this).attr('rel'));
				});
				jQuery(protocols).map(function() {
					protocol = this;
					if (link.href.startsWith(protocol)) {
						jQuery('#external_url').val(link.href.gsub(protocol, ""));
						jQuery('#url_protocol_select').trigger('alchemy_selectbox:select', {
							value: protocol
						});
						jQuery('#extern_link_title').val(title);
						jQuery('#link_target').attr('checked', link.target == "_blank");
					}
				});
			}
			
			// Handling a file link.
			if (link.className == 'file') {
				Alchemy.showLinkWindowTab('#overlay_tab_file_link');				
				jQuery('#file_link_title').val(title);
				jQuery('#public_filename_select').trigger('alchemy_selectbox:select', {
					value: link.pathname
				});
				jQuery('#file_link_target').checked = link.target == "_blank";
			}
			
			// Handling a contactform link.
			if (link.className == 'contact') {
				var link_url = link.pathname;
				var link_params = link.href.split('?')[1];
				var link_subject = link_params.split('&')[0];
				var link_mailto = link_params.split('&')[1];
				var link_body = link_params.split('&')[2];
				Alchemy.showLinkWindowTab('#overlay_tab_contactform_link');
				jQuery('#contactform_link_title').val(title);
				jQuery('#contactform_url').val(link_url);
				jQuery('#contactform_subject').val(unescape(link_subject.gsub(/subject=/, '')));
				jQuery('#contactform_body').val(unescape(link_body.gsub(/body=/, '')));
				jQuery('#contactform_mailto').val(link_mailto.gsub(/mail_to=/, ''));
			}
		}
	},
	
	createTempLink : function(linked_element) {
		var $tmp_link = jQuery("<a></a>");
		var essence_type = linked_element.attr('name').gsub('essence_', '').split('_')[0];
		switch (essence_type) {
		case "picture":
			var content_id = linked_element.attr('name').gsub('essence_picture_', '');
			break;
		case "text":
			var content_id = linked_element.attr('name').gsub('essence_text_', '');
			break;
		}
		$tmp_link.attr('href', jQuery('#content_' + content_id + '_link').val());
		$tmp_link.attr('title', jQuery('#content_' + content_id + '_link_title').val());
		if (jQuery('#content_' + content_id + '_link_target').val() == '1') {
			$tmp_link.attr('target', '_blank');
		}
		$tmp_link.addClass(jQuery('#content_' + content_id + '_link_class_name').val());
		return $tmp_link;
	},
	
	showLinkWindowTab : function(id) {
		jQuery('#overlay_tabs').tabs("select", id);
	},
	
	fadeImage : function(image) {
		try {
			var $image = jQuery(image);
			$image.parent().parent().prev().hide();
			$image.parent().parent().fadeIn(600);
		} catch(e) {
			Alchemy.debug(e);
		};
	},
	
	saveElement : function(form, element_id) {
		var $rtf_contents = jQuery('#element_'+element_id+' div.content_rtf_editor');
		if ($rtf_contents.size() > 0) {
			// collecting all rtf elements and fire the Alchemy.saveElementAjaxRequest after the last tinymce.save event!
			$rtf_contents.map(function() {
				var $rtf_content = jQuery(this);
				var $text_area = $rtf_content.children('textarea');
				var editor = tinyMCE.get($text_area.attr('id'));
				if ($rtf_content.get(0) == $rtf_contents.last().get(0)) {
					editor.onSaveContent.add(function(ed, o) {
						// delaying the ajax call, so that tinymce has enough time to save the content.
						setTimeout(function(){Alchemy.saveElementAjaxRequest(form, element_id);}, 500);
					});
				}
				//removing the editor instance before adding it dynamically after saving
				// $(editor.editorId).previous('div.essence_richtext_loader').show();
				// tinyMCE.execCommand('mceRemoveControl', true, editor.editorId);
				editor.save();
			});
		} else {
			Alchemy.saveElementAjaxRequest(form, element_id);
		}
		return false;
	},
	
	saveElementAjaxRequest : function (form, element_id) {
		//return true;
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
	},
	
	debug : function(e) {
		if (window['console']) {
			console.debug(e);
		}
	}
	
};

// Call all Alchemy "onload" scripts
jQuery(document).ready(function () {
	jQuery('body#alchemy select').sb({animDuration: 0});
	if (jQuery('#flash_notices').length > 0) {
		jQuery('#flash_notices div[class!="flash error"] ').delay(5000).hide('drop', { direction: "up" }, 400);
	}
});

function scrollToElement(id) {
	var el_ed = $('element_' + id);
	if (el_ed) {
		var offset = el_ed.positionedOffset();
		var container = jQuery('#alchemyOverlay');
		container.scrollTop = offset.top - 41;
	}
}

function toggleButton(id, action) {
	var button = $(id);
	if (action == 'disable') {
		button.addClassName('disabled');
		var div = new Element('div', {
			'class': 'disabledButton'
		});
		button.insert({
			top: div
		});
	} else if (action == 'enable') {
		button.removeClassName('disabled');
		button.down('div.disabledButton').remove();
	};
}

function isIe() {
	return typeof(document.all) == 'object';
}

function foldPage(id) {
    var button = $("fold_button_" + id);
    var folded = button.hasClassName('folded');
    if (folded) {
        button.removeClassName('folded');
        button.addClassName('collapsed');
    } else {
        button.removeClassName('collapsed');
        button.addClassName('folded');
    }
    $("page_" + id + "_children").toggle();
}

function mass_set_selected(select, selector, hiddenElementParentCount) {
    boxes = $$(selector);
    for (var i = 0; i < boxes.length; i++) {
        hiddenElement = boxes[i];
        $R(0, hiddenElementParentCount - 1).each(function(s) {
            hiddenElement = hiddenElement.parentNode;
        });
        boxes[i].checked = (hiddenElement.style.display == "") ? (select == "inverse" ? !boxes[i].checked: select) : boxes[i].checked;
    }
}

function toggle_label(element, labelA, labelB) {
    element = $(element);
    if (element) {
        if (element.tagName == "INPUT") {
            element.value = (element.value == labelA ? labelB: labelA);
        } else {
            element.update(element.innerHTML == labelA ? labelB: labelA);
        }
    }
}

function selectPageForInternalLink(selected_element, urlname) {
    $('page_anchor').removeAttribute('value');
    // We have to remove the Attribute. If not the value does not get updated.
    $$('.elements_for_page').invoke('hide');
    $('internal_urlname').value = '/' + urlname;
    $$('#sitemap_for_links .selected_page').invoke('removeClassName', 'selected_page');
    var sel = $('sitemap_sitename_' + selected_element);
    sel.addClassName('selected_page');
    sel.name = urlname;
}

function selectFileForFileLink(selected_element, public_filename) {
    jQuery('#public_filename').val(public_filename);
    jQuery('#file_links .selected_file').map(function() {
    	jQuery(this).removeClass('selected_file');
    });
    jQuery('#assign_file_' + selected_element).addClass('selected_file');
}

function alchemyUnlink(ed) {
    var link = ed.selection.getNode();
    var content = link.innerHTML;
    ed.dom.remove(link);
    ed.selection.setContent(content);
    var unlink_button = ed.controlManager.get('alchemy_unlink');
    var link_button = ed.controlManager.get('alchemy_link');
    unlink_button.setDisabled(true);
    link_button.setDisabled(true);
    link_button.setActive(false);
}

function removePictureLink(content_id) {
    jQuery('#content_' + content_id + '_link').val('');
    jQuery('#content_' + content_id + '_link_title').val('');
    jQuery('#content_' + content_id + '_link_class_name').val('');
    jQuery('#content_' + content_id + '_link_target').val('');
    jQuery('#edit_link_' + content_id).removeClass('linked');
}

function alchemyCreateLink(link_type, url, title, extern) {
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
        var essence_type = element.name.gsub('essence_', '').split('_')[0];
        switch (essence_type) {
        case "picture":
            var content_id = element.name.gsub('essence_picture_', '');
            break;
        case "text":
            var content_id = element.name.gsub('content_text_', '');
            break;
        }
        $('content_' + content_id + '_link').value = url;
        $('content_' + content_id + '_link_title').value = title;
        $('content_' + content_id + '_link_class_name').value = link_type;
        $('content_' + content_id + '_link_target').value = (extern ? '1': '0');
    }
}

// creates a link to a javascript function
function alchemyCreateLinkToFunction(link_type, func, title) {
	var tiny_ed = Alchemy.CurrentLinkWindow.linked_element.editor;
	var link = null;
	if (tiny_ed.selection) {
		if (tiny_ed.selection.getNode().nodeName == "A") {
			// updating link
			link = tiny_ed.selection.getNode();
			tiny_ed.dom.setAttribs(link, {
				href: '#',
				title: title,
				'class': link_type,
				onclick: func
			});
		} else {
			// creating new link
			link = tiny_ed.dom.create(
			'a',
			{
				href: '#',
				title: title,
				'class': link_type,
				onclick: func
			},
			tiny_ed.selection.getContent()
			);
			tiny_ed.selection.setNode(link);
		}
		tiny_ed.save();
	}
}

function showElementsFromPageSelector(id) {
	jQuery('#elements_for_page_' + id).show();
	page_select_scrollbar.scrollTo($('sitemap_sitename_' + id));
	page_select_scrollbar.recalculateLayout();
}

function hideElementsFromPageSelector(id) {
	jQuery('#elements_for_page_' + id).hide();
	jQuery('#page_anchor').removeAttr('value');
	page_select_scrollbar.scrollTo($('sitemap_sitename_' + id));
	page_select_scrollbar.recalculateLayout();
}

function createSortableTree() {
    var tree = new SortableTree(
    $('sitemap'),
    {
        draggable: {
            ghosting: true,
            reverting: true,
            handle: 'handle',
            scroll: window,
            starteffect: function(element) {
                new Effect.Opacity(element, {
                    from: 1.0,
                    to: 0.2,
                    duration: 0.2
                });
            }
        },
        onDrop: function(drag, drop, event) {
            Alchemy.pleaseWaitOverlay();
            new Ajax.Request(
            '/admin/pages/move',
            {
                postBody: drag.to_params(),
                onComplete: function() {
                    var overlay = $('overlay');
                    if (overlay)
                    overlay.style.visibility = 'hidden';
                }
            }
            );
        }
    }
    );
    tree.setSortable();
}

// Javascript extensions

String.prototype.beginsWith = function(t, i) {if (i==false) { return 
(t == this.substring(0, t.length)); } else { return (t.toLowerCase() 
== this.substring(0, t.length).toLowerCase()); } } 

String.prototype.endsWith = function(t, i) { if (i==false) { return (t 
== this.substring(this.length - t.length)); } else { return 
(t.toLowerCase() == this.substring(this.length - 
t.length).toLowerCase()); } }
