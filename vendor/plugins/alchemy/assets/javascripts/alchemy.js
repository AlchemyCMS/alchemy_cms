var is_ie = (document.all) ? true : false;

function wa_overlay_window(action_url, title, size_x, size_y, resizable, modal, overflow){
	overflow == undefined ? overflow = false : overflow = overflow;
	wa_overlay = new Window({
		className: 'wa_window',
		title: title,
		width: size_x,
		height: size_y,
		minWidth: size_x,
		minHeight: size_y,
		maximizable: false,
		minimizable: false,
		resizable: true,
		draggable: true,
		zIndex: 300000,
		closable: true,
		destroyOnClose: true,
		recenterAuto: false,
		effectOptions: {
			duration: 0.2
		}
	});
	wa_overlay.setZIndex(10);
	wa_overlay.setAjaxContent(action_url, {
		method: 'get',
		onLoading: function () {
			var spinner = new Image();
			spinner.src = "/plugin_assets/alchemy/images/ajax_loader.gif";
			spinner.setStyle({
				marginLeft: (size_x - 32) / 2 + 'px',
				marginTop: (size_y - 32) / 2 + 'px'
			});
			$$('div.wa_window_content')[0].insert(spinner);
			wa_overlay.spinner = spinner;
		},
		onComplete: function () {
			wa_overlay.spinner.remove();
		}
	});
	if (overflow == 'true') {
		wa_overlay.getContent().setStyle({overflow: 'visible'});
		wa_overlay.getContent().up().setStyle({overflow: 'visible'});
	};
	wa_overlay.showCenter(modal == 'true' ? 'modal' : null);
}

function image_zoom(url, title, width, height) {
	var window_height = height;
	var window_width = width;
	if (width > document.viewport.getWidth()) {
		window_width = document.viewport.getWidth() - 30;
	}
	if (height > document.viewport.getHeight()) {
		window_height = document.viewport.getHeight() - 50;
	}
	image_window = new Window({
		className: "wa_window",
		title: title,
		width: window_width,
		height: window_height,
		minWidth: 320,
		minHeight: 240,
		url: url,
		resizable: true,
		destroyOnClose: true,
		maximizable: false,
		minimizable: false,
		recenterAuto: false,
		zIndex: 300000,
		effectOptions: {
			duration: 0.2
		}
	});
	image_window.showCenter();
}

function wa_link_window(selElem, width) {
    wa_overlay = new Window({
        className: "wa_window",
        title: 'Link setzen',
        width: width,
        height: '410',
        zIndex: 300000,
        maximizable: false,
        resizable: true,
        draggable: true,
        closable: true,
        destroyOnClose: true,
        recenterAuto: false,
        showEffect: Effect.Appear,
        hideEffect: Effect.Fade,
        effectOptions: {
            duration: 0.2
        }
    });
    // IE 7 Syntax Error: Bezeichner erwartet.
    wa_overlay.tiny_ed = selElem;
    //
    wa_overlay.setAjaxContent('/alchemy/link_to_page', {method: 'get'});
    wa_overlay.showCenter('modal');
}

function OverlayForMolecules(show) {
	var a = $$(".content_fckeditor");
	if (show) {
		a.invoke('hide');
	}
	else {
		a.invoke('show');
	}
}

function pleaseWaitOverlay(message) {
	var overlay = $('overlay');
	if (overlay)
		overlay.style.visibility = 'visible';
}

function isIe() {
	return typeof document.all == 'object';
}

function fold_page(id) {
	var button = $("fold_button_" + id);
	var folded = $("page_" + id + "_children").getStyle('display') == 'none';
	var offset = folded ? 15 : -15;
	button.setStyle({
	  backgroundPosition: parseInt(button.getStyle('backgroundPosition')) + offset + 'px 0'
	});
	$("page_" + id + "_children").toggle();
}

function reloadPreview() {
    var frame = $('preview_frame');
    if (frame){
        if (is_ie) {
            var doc = frame.contentWindow.document;
        } else {
            var doc = frame.contentDocument;
        }
        if (doc) {
            doc.location.reload(true);
        }
    }
}

function wa_filter(selector){
	text = $('search_field').value.toLowerCase();
	boxes = $$(selector);
	for (var i=0; i < boxes.length; i++) {
		boxes[i].style.display = (boxes[i].readAttribute('name').toLowerCase().indexOf(text) != -1) ? "" : "none";
	}
}

function mass_set_selected(select, selector, hiddenElementParentCount) {
	boxes = $$(selector);
	for (var i=0; i < boxes.length; i++) {
		hiddenElement = boxes[i];
		$R(0,hiddenElementParentCount-1).each(function(s){hiddenElement = hiddenElement.parentNode;});
		boxes[i].checked = (hiddenElement.style.display == "") ? (select == "inverse" ? !boxes[i].checked : select) : boxes[i].checked;
	}
}

function hide_overlay_tabs () {
	$$('.wa_overlay_tab_body').invoke('hide');
	$$('.wa_overlay_tab').invoke('removeClassName', 'active');
}

function show_overlay_tab (id, tab) {
	hide_overlay_tabs();
	$(id).show();
	tab.addClassName('active');
}

function toggle_label (element, labelA, labelB) {
    element = $(element);
    if (element) {
        if (element.tagName == "INPUT") {
            element.value = (element.value == labelA ? labelB : labelA);
        } else {
            element.update(element.innerHTML == labelA ? labelB : labelA);
        }
    }
}

function selectPageForInternalLink (selected_element, urlname) {
    $('page_anchor').removeAttribute('value'); // We have to remove the Attribute. If not the value does not get updated.
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
    $('wa_assign_file_' + selected_element).addClassName('selected_file');
}

function waUnLink (ed) {
    var link = ed.selection.getNode();
    var content = link.innerHTML;
    ed.dom.remove(link);
    ed.selection.setContent(content);
    var unlink_button = ed.controlManager.get('wa_unlink');
    var link_button = ed.controlManager.get('wa_link');
    unlink_button.setDisabled(true);
    link_button.setDisabled(true);
    link_button.setActive(false);
}

function waCreateLink(link_type, url, title, extern) { 
	var tiny_ed = wa_overlay.tiny_ed;
	if (tiny_ed.selection) {
			// aka we are linking text inside of TinyMCE 
			tiny_ed.execCommand('mceInsertLink', false, {
				href: url,
				'class': link_type,
				title: title,
				target: (extern ? '_blank' : null)
			});
	} else {
		// aka: we are linking an atom
		var atom_type = tiny_ed.name.gsub('content_', '').split('_')[0];
		switch (atom_type) {
			case "picture": var atom_id = tiny_ed.name.gsub('content_picture_', '');
			break;
			case "text": var atom_id = tiny_ed.name.gsub('content_text_', '');
			break;
		}
		$('atom_' + atom_id + '_link').value = url;
		$('atom_' + atom_id + '_link_title').value = title;
		$('atom_' + atom_id + '_link_class_name').value = link_type;
		$('atom_' + atom_id + '_link_target').value = (extern ? '1' : '0');
	}
}

// creates a link to a javascript function
function waCreateLinkToFunction(link_type, func, title) {  
  var tiny_ed = wa_overlay.tiny_ed;
  if (tiny_ed.selection) {
    if( tiny_ed.selection.getNode().nodeName == "A" ) {
      // updating link
      var link = tiny_ed.selection.getNode();
      tiny_ed.dom.setAttribs(link, {
        href : '#',
        title: title,
        'class': link_type,
        onclick: func
      });
    } else {
      // creating new link
      var link = tiny_ed.dom.create(
        'a',
        {
          href : '#',
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

// Das Monster das dafür sorgt, dass wenn man einen link im TinyMCE ausgewählt hat
// der entsprechende Tab im verlinken Overlay angezeigt wird.
// Füllt ausserdem die Felder aus (title, href, etc.).
// Klassisches "javascript-mit-der-groben-kelle".
function select_link_tab() {
    var tiny_ed = wa_overlay.tiny_ed;
    if (tiny_ed.selection == undefined) {
        var tmp_link = document.createElement("a");
        var selection = tiny_ed;
				var atom_type = tiny_ed.name.gsub('content_', '').split('_')[0];
				switch (atom_type) {
					case "picture": var atom_id = tiny_ed.name.gsub('content_picture_', '');
					break;
					case "text": var atom_id = tiny_ed.name.gsub('content_text_', '');
					break;
				}
        tmp_link.href = $('atom_' + atom_id + '_link').value;
        tmp_link.title = $('atom_' + atom_id + '_link_title').value;
        tmp_link.target = ($('atom_' + atom_id + '_link_target').value == '1' ? '_blank' : '');
        tmp_link.className = $('atom_' + atom_id + '_link_class_name').value;
        var link = tmp_link;
    } else {
        var link = tiny_ed.selection.getNode();
    }
    if (link.nodeName == "A") {
        var title = link.title == null ? "" : link.title;
        if ((link.className == '') || link.className == 'internal') {
          var internal_anchor = link.hash.split('#')[1];
          var internal_urlname = link.pathname;
          show_overlay_tab('sitemap_for_links', $('tab_for_sitemap_for_links'));
          $('internal_link_title').value = title;
          $('internal_urlname').value = internal_urlname;
          $('internal_link_target').checked = (link.target == "_blank");
          var sitemap_line = $$('.sitemap_sitename').detect(function(f) {
              return internal_urlname == f.readAttribute('name');
          });
          if (sitemap_line) {
            // select the line where the link was detected in.
            sitemap_line.addClassName("selected_page");
            page_select_scrollbar.scrollTo(sitemap_line.up('li'));
            // is there an anchor in the url? then request the element selector via ajax and select the correct value. yeah!
            if (internal_anchor) {
              var select_container = $(sitemap_line).adjacent('.elements_for_page').first();
              select_container.show();
              new Ajax.Request("/elements/?page_urlname=" + internal_urlname.split('/').last(), {
                method: 'get',
                onComplete: function() {
                  var wa_select = select_container.down('.alchemy_selectbox');
                  $('page_anchor').value = '#' + internal_anchor;
                  // sadly this does not work here. maybe later i have the knowledge to fix this.
                  var select = waSelectbox.findSelectById(wa_select.identify());
                  select.selectValue('#' + internal_anchor);
                }
              });
            }
          }
        }
        if ( link.className == 'external' ) {
            show_overlay_tab('sitemap_external_links', $('tab_for_sitemap_external_links'));
            protocols = $('url_protocol_select').select('.alchemy_selectbox_body a').pluck('rel');
            protocols.each(function(p) {
                if ( link.href.startsWith(p) ) {
                    $('external_url').value = link.href.gsub(p, "");
                    $('url_protocol_select').fire('wa_select:select', {value: p});
                    $('extern_link_title').value = title;
                    $('link_target').checked = (link.target == "_blank");
                }
            });
        }
        if ( link.className == 'file' ) {
            show_overlay_tab('file_links', $('tab_for_file_links'));
            $('file_link_title').value = title;
            $('public_filename_select').fire('wa_select:select', {value: link.pathname});
            $('file_link_target').checked = link.target == "_blank";
        }
        if ( link.className == 'contact' ) {
						var link_url = link.pathname;
						var link_params = link.href.split('?')[1];
						var link_subject = link_params.split('&')[0];
						var link_mailto = link_params.split('&')[1];
						show_overlay_tab('contactform_links', $('tab_for_contactform_links'));
						$('contactform_link_title').value = title;
						$('contactform_url').value = link_url;
						$('contactform_subject').value = unescape(link_subject.gsub(/subject=/,''));
						$('contactform_mailto').value = link_mailto.gsub(/mail_to=/,'');
        }
    }
}

function fadeWaFlashNotice() {
    $('flash_notice').fade({duration:0.5});
    setFrameSize();
}

function showMoleculesFromPageSelector (id) {
    $('elements_for_page_' + id).show();
    page_select_scrollbar.scrollTo($('sitemap_sitename_' + id));
    page_select_scrollbar.recalculateLayout();
}

function hideMoleculesFromPageSelector (id) {
    $('elements_for_page_' + id).hide();
    $('page_anchor').removeAttribute('value');
    page_select_scrollbar.scrollTo($('sitemap_sitename_' + id));
    page_select_scrollbar.recalculateLayout();
}

function wa_fade_image(image) {
	try {
		image.up().up().previous().hide();
		image.up().up().appear({duration: 0.6});
	} catch(e){};
}

// Used for saving the rtf atom content from tinymce.
function saveRtfAtoms (element_id) {
	var element = $('element_'+element_id);
	if (element) {
		var rtf_atoms = element.select('textarea.tinymce');
		rtf_atoms.each(function (atom) {
			var editor = tinyMCE.get(atom.id);
			var content = editor.getContent();
			$(editor.editorId).value = content;
			//removing the editor instance before adding it dynamically after saving
			$(editor.editorId).previous('div.content_rtf_loader').show();
			tinyMCE.execCommand(
				'mceRemoveControl',
				true,
				editor.editorId
			);
		});		
	}
}
