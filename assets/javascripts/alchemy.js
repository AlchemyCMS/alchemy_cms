var Alchemy = {};

Alchemy.inPlaceEditor = function (options) {
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
		onBlurDisabled : true,
		html : ' \
	          <div class="inplace-edit"> \
	            <input type="text" value="" class="thin_border field" /> \
	            <div class="buttons"> \
	              <input type="button" value="'+settings.save_label+'" class="save-button button" /> \
	              <input type="button" value="'+settings.cancel_label+'" class="cancel-button button" /> \
	            </div> \
	          </div>'
	});
	
};

var is_ie = (document.all) ? true: false;

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

var AlOpenPreviewWindow = function (url, title) {
	var $iframe = jQuery('<iframe src="'+url+'" id="alchemyPreviewWindow"></iframe>');
	jQuery.fx.speeds._default = 400;
	AlchemyPreviewWindow = $iframe.dialog({
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
	AlchemyPreviewWindow.refresh = function () {
		var $iframe = jQuery('#alchemyPreviewWindow');
		$iframe.attr('src', $iframe.attr('src'));
	}
};

var AlOpenElementsWindow = function (path, title) {
	var $dialog = jQuery('<div style="display:none" id="alchemyOverlay"></div>');
	jQuery.fx.speeds._default = 400;
	AlchemyElementWindow = $dialog.dialog({
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
					$dialog.html('<h1>' + XMLHttpRequest.status + '</h1>');
					switch (XMLHttpRequest.status) {
						case 404: $dialog.append('<p>Diese Seite wurde nicht gefunden!</p>');
						break;
						case 500: $dialog.append('<p>Entschuldigung!</p><p>Es ist leider ein Fehler passiert.</p>');
						break;
						default: $dialog.append('<p></p>');
					}
				}
			});
		},
		close: function () {
			$dialog.remove();
		}
	});
};

var AlConfirmWindow = function (url, title, message, ok_lable, cancel_label) {
	var confirmation = jQuery('<div style="display:none" id="alchemyConfirmation"></div>').appendTo('body');
	confirmation.html('<p>'+message+'</p>');
	confirmation.dialog({
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
}

var AlOverlayWindow = function (action_url, title, size_x, size_y, resizable, modal, overflow) {
    overflow == undefined ? overflow = false: overflow = overflow;
    if (size_x === 'fullscreen') {
        size_x = jQuery(window).width() - 50;
        size_y = jQuery(window).height() - 50;
    }
		var $dialog = jQuery('<div style="display:none" id="alchemyOverlay"></div>');
		$dialog.appendTo('body');
		var $spinner = jQuery('<img src="/images/alchemy/ajax_loader.gif" />');
		$spinner.css({
			marginLeft: (size_x - 40) / 2,
			marginTop: (size_y - 50) / 2
		});
		$dialog.html($spinner);
		jQuery.fx.speeds._default = 400;
		AlchemyWindow = $dialog.dialog({
			modal: modal, 
			minWidth: size_x, 
			minHeight: size_y,
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
						jQuery('#alchemy .ui-dialog').css({overflow: overflow ? 'visible' : 'auto'});
					},
					error: function(XMLHttpRequest, textStatus, errorThrown) {
						$dialog.html('<h1>' + XMLHttpRequest.status + '</h1>');
						switch (XMLHttpRequest.status) {
							case 404: $dialog.append('<p>Diese Seite wurde nicht gefunden!</p>');
							break;
							case 500: $dialog.append('<p>Entschuldigung!</p><p>Es ist leider ein Fehler passiert.</p>');
							break;
							default: $dialog.append('<p></p>');
						}
					}
				});
			},
			close: function () {
				$dialog.remove();
			}
		});
		return false;
};

var AlZoomImage = function(url, title, width, height) {
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
	var $spinner = jQuery('<img src="/images/alchemy/ajax_loader.gif" />');
	$spinner.css({
		marginLeft: (window_width - 24) / 2,
		marginTop: (window_height - 0) / 2
	});
	$dialog.html($spinner);
	jQuery.fx.speeds._default = 400;
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
					$dialog.html('<h1>' + XMLHttpRequest.status + '</h1>');
					switch (XMLHttpRequest.status) {
						case 404: $dialog.append('<p>Diese Seite wurde nicht gefunden!</p>');
						break;
						case 500: $dialog.append('<p>Entschuldigung!</p><p>Es ist leider ein Fehler passiert.</p>');
						break;
						default: $dialog.append('<p></p>');
					}
				}
			});
		},
		close: function () {
			$dialog.remove();
		}
	});
	return false;
};

var AlOpenLicencseWindow = function() {
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
};

var AlOpenLinkWindow = function (linked_element, width) {
	var $dialog = jQuery('<div style="display:none" id="alchemyLinkOverlay"></div>');
	jQuery.fx.speeds._default = 400;
	link_window = $dialog.dialog({
		modal: true, 
		minWidth: width, 
		minHeight: 410,
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
					$dialog.html('<h1>' + XMLHttpRequest.status + '</h1>');
					switch (XMLHttpRequest.status) {
						case 404: $dialog.append('<p>Diese Seite wurde nicht gefunden!</p>');
						break;
						case 500: $dialog.append('<p>Entschuldigung!</p><p>Es ist leider ein Fehler passiert.</p>');
						break;
						default: $dialog.append('<p></p>');
					}
				}
			});
		},
		close: function () {
			$dialog.remove();
		}
	});
	link_window.linked_element = linked_element;
};

var pleaseWaitOverlay = function(show) {
	if (typeof(show) == 'undefined') {
		show = true;
	}
	var $overlay = jQuery('#overlay');
	$overlay.css("visibility", show ? 'visible': 'hidden');
};

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

function reloadPreview() {
    AlchemyPreviewWindow.refresh();
}

function alchemyListFilter(selector) {
    text = $('search_field').value.toLowerCase();
    boxes = $$(selector);
    for (var i = 0; i < boxes.length; i++) {
        boxes[i].style.display = (boxes[i].readAttribute('name').toLowerCase().indexOf(text) != -1) ? "": "none";
    }
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

function hide_overlay_tabs() {
    $$('.link_window_tab_body').invoke('hide');
    $$('.link_window_tab').invoke('removeClassName', 'active');
}

function showLinkWindowTab(id, tab) {
    hide_overlay_tabs();
    $(id).show();
    tab.addClassName('active');
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
    $('public_filename').value = public_filename;
    $$('#file_links .selected_file').invoke('removeClassName', 'selected_file');
    $('assign_file_' + selected_element).addClassName('selected_file');
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
    $('content_' + content_id + '_link').value = '';
    $('content_' + content_id + '_link_title').value = '';
    $('content_' + content_id + '_link_class_name').value = '';
    $('content_' + content_id + '_link_target').value = '';
    $('edit_link_' + content_id).removeClassName('linked');
}

function alchemyCreateLink(link_type, url, title, extern) {
    var element = link_window.linked_element;
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
    var tiny_ed = link_window.linked_element.editor;
    if (tiny_ed.selection) {
        if (tiny_ed.selection.getNode().nodeName == "A") {
            // updating link
            var link = tiny_ed.selection.getNode();
            tiny_ed.dom.setAttribs(link, {
                href: '#',
                title: title,
                'class': link_type,
                onclick: func
            });
        } else {
            // creating new link
            var link = tiny_ed.dom.create(
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

// Selects the tab for kind of link and fills all fields.
// TODO: Make this a class!
function selectLinkWindowTab() {
    var linked_element = link_window.linked_element;

    // Creating an temporary anchor node if we are linking an EssencePicture or EssenceText.
    if (linked_element.nodeType) {
        var tmp_link = document.createElement("a");
        var essence_type = linked_element.name.gsub('essence_', '').split('_')[0];
        switch (essence_type) {
        case "picture":
            var content_id = linked_element.name.gsub('essence_picture_', '');
            break;
        case "text":
            var content_id = linked_element.name.gsub('essence_text_', '');
            break;
        }
        tmp_link.href = $('content_' + content_id + '_link').value;
        tmp_link.title = $('content_' + content_id + '_link_title').value;
        tmp_link.target = ($('content_' + content_id + '_link_target').value == '1' ? '_blank': '');
        tmp_link.className = $('content_' + content_id + '_link_class_name').value;
        var link = tmp_link;
    }

    // Restoring the bookmarked selection inside the TinyMCE of an EssenceRichtext.
    else {
        var link = linked_element.node;
        linked_element.selection.moveToBookmark(linked_element.bookmark);
    }

    // Checking of what kind the link is (internal, external, file or contact_form).
    if (link.nodeName == "A") {
        var title = link.title == null ? "": link.title;

        // Handling an internal link.
        if ((link.className == '') || link.className == 'internal') {
            var internal_anchor = link.hash.split('#')[1];
            var internal_urlname = link.pathname;
            showLinkWindowTab('sitemap_for_links', $('tab_for_sitemap_for_links'));
            $('internal_link_title').value = title;
            $('internal_urlname').value = internal_urlname;
            $('internal_link_target').checked = (link.target == "_blank");
            var sitemap_line = $$('.sitemap_sitename').detect(function(f) {
                return internal_urlname == f.readAttribute('name');
            });
            if (sitemap_line) {
                // Select the line where the link was detected in.
                sitemap_line.addClassName("selected_page");
                page_select_scrollbar.scrollTo(sitemap_line.up('li'));
                // is there an anchor in the url? then request the element selector via ajax and select the correct value. yeah!
                if (internal_anchor) {
                    var select_container = $(sitemap_line).adjacent('.elements_for_page').first();
                    select_container.show();
                    new Ajax.Request("/admin/elements/?page_urlname=" + internal_urlname.split('/').last(), {
                        method: 'get',
                        onComplete: function() {
                            var alchemy_selectbox = select_container.down('.alchemy_selectbox');
                            $('page_anchor').value = '#' + internal_anchor;
                            // badly this does not work here. maybe later i have the knowledge to fix this.
                            var select = AlchemySelectbox.findSelectById(alchemy_selectbox.id);
                            select.fire('alchemy_selectbox:select', {
                                value: '#' + internal_anchor
                            });
                        }
                    });
                }
            }
        }

        // Handling an external link.
        if (link.className == 'external') {
            showLinkWindowTab('sitemap_external_links', $('tab_for_sitemap_external_links'));
            protocols = $('url_protocol_select').select('.alchemy_selectbox_body a').pluck('rel');
            protocols.each(function(p) {
                if (link.href.startsWith(p)) {
                    $('external_url').value = link.href.gsub(p, "");
                    $('url_protocol_select').fire('alchemy_selectbox:select', {
                        value: p
                    });
                    $('extern_link_title').value = title;
                    $('link_target').checked = (link.target == "_blank");
                }
            });
        }

        // Handling a file link.
        if (link.className == 'file') {
            showLinkWindowTab('file_links', $('tab_for_file_links'));
            $('file_link_title').value = title;
            $('public_filename_select').fire('alchemy_selectbox:select', {
                value: link.pathname
            });
            $('file_link_target').checked = link.target == "_blank";
        }

        // Handling a contactform link.
        if (link.className == 'contact') {
            var link_url = link.pathname;
            var link_params = link.href.split('?')[1];
            var link_subject = link_params.split('&')[0];
            var link_mailto = link_params.split('&')[1];
            var link_body = link_params.split('&')[2];
            showLinkWindowTab('contactform_links', $('tab_for_contactform_links'));
            $('contactform_link_title').value = title;
            $('contactform_url').value = link_url;
            $('contactform_subject').value = unescape(link_subject.gsub(/subject=/, ''));
            $('contactform_body').value = unescape(link_body.gsub(/body=/, ''));
            $('contactform_mailto').value = link_mailto.gsub(/mail_to=/, '');
        }
    }
}

function showElementsFromPageSelector(id) {
    $('elements_for_page_' + id).show();
    page_select_scrollbar.scrollTo($('sitemap_sitename_' + id));
    page_select_scrollbar.recalculateLayout();
}

function hideElementsFromPageSelector(id) {
    $('elements_for_page_' + id).hide();
    $('page_anchor').removeAttribute('value');
    page_select_scrollbar.scrollTo($('sitemap_sitename_' + id));
    page_select_scrollbar.recalculateLayout();
}

function alchemyImageFade(image) {
    try {
        image.up().up().previous().hide();
        image.up().up().appear({
            duration: 0.6
        });
    } catch(e) {};
}

function saveElement(form, element_id) {
    var rtf_contents = $$('#element_'+element_id+' div.content_rtf_editor');
    if (rtf_contents.size() > 0) {
        // collecting all rtf elements and fire the saveElementAjaxRequest after the last tinymce.save event!
        rtf_contents.each(function (rtf_content) {
            var text_area = rtf_content.down('textarea');
            var editor = tinyMCE.get(text_area.id);
            if (rtf_content == rtf_contents.last()) {
                editor.onSaveContent.add(function(ed, o) {
                    // delaying the ajax call, so that tinymce has enough time to save the content.
                    setTimeout(function(){saveElementAjaxRequest(form, element_id);}, 500);
                });
            }
            //removing the editor instance before adding it dynamically after saving
            // $(editor.editorId).previous('div.essence_richtext_loader').show();
            // tinyMCE.execCommand('mceRemoveControl', true, editor.editorId);
            editor.save();
        });
    } else {
        saveElementAjaxRequest(form, element_id);
    }
    return false;
}

function saveElementAjaxRequest (form, element_id) {
    new Ajax.Request('/admin/elements/' + element_id, {
        asynchronous: true,
        evalScripts: true,
        method: 'put',
        onComplete: function(request) {
            $('element_'+element_id+'_save').show();
            $('element_'+element_id+'_spinner').hide();
        },
        onLoading: function(request) {
            $('element_'+element_id+'_save').hide();
            $('element_'+element_id+'_spinner').show();
        },
        parameters: Form.serialize(form)
    });
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
            pleaseWaitOverlay();
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
