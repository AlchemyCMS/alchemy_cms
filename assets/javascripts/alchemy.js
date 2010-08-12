var is_ie = (document.all) ? true : false;

function scrollToElement (id) {
	var el_ed = $('element_'+id);
	var offset = el_ed.positionedOffset();
	var container = $$('.alchemy_window_content .alchemy_window_content').first();
	container.scrollTop = offset.top - 41;
}

function toggleButton (id, action) {
	var button = $(id);
	if (action == 'disable') {
		button.addClassName('disabled');
		var div = new Element('div', {'class' : 'disabledButton'});
		button.insert({top: div});
	} else if (action == 'enable') {
		button.removeClassName('disabled');
		button.down('div.disabledButton').remove();
	};
}

function openPreviewWindow (url, title) {
	preview_window = new Window({
		url: url,
		className: 'alchemy_window',
		title: title,
		width: document.viewport.getDimensions().width - 570,
		height: document.viewport.getDimensions().height - 135,
		minWidth: 600,
		minHeight: 300,
		maximizable: false,
		minimizable: false,
		resizable: true,
		draggable: true,
		zIndex: 30000,
		closable: false,
		destroyOnClose: true,
		recenterAuto: false,
		effectOptions: {
			duration: 0.2
		}
	});
	preview_window.showCenter(false, 97, 92);
}

function openElementsWindow (page_id, title) {
	elements_window = new Window({
		className: 'alchemy_window',
		title: title,
		width: 424,
		height: document.viewport.getDimensions().height - 155,
		minWidth: 424,
		minHeight: 300,
		maxHeight: document.viewport.getDimensions().height - 155,
		maximizable: false,
		minimizable: false,
		resizable: true,
		draggable: true,
		zIndex: 30000,
		closable: false,
		destroyOnClose: true,
		recenterAuto: false,
		effectOptions: {
			duration: 0.2
		}
	});
	elements_window.setAjaxContent('/admin/elements/list?page_id=' + page_id, {method: 'get'});
	elements_window.showCenter(false, 107, document.viewport.getDimensions().width - 450);
}

function openOverlayWindow(action_url, title, size_x, size_y, resizable, modal, overflow){
	overflow == undefined ? overflow = false : overflow = overflow;
	if (size_x === 'fullscreen') {
	  size_x = document.viewport.getWidth() - 50;
		size_y = document.viewport.getHeight() - 100;
	}
	alchemy_window = new Window({
		className: 'alchemy_window',
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
	alchemy_window.setZIndex(10);
	alchemy_window.setAjaxContent(action_url, {
		method: 'get',
		onLoading: function () {
			var spinner = new Image();
			spinner.src = "/plugin_assets/alchemy/images/ajax_loader.gif";
			spinner.setStyle({
				marginLeft: (size_x - 32) / 2 + 'px',
				marginTop: (size_y - 32) / 2 + 'px'
			});
			$$('div.alchemy_window_content')[0].insert(spinner);
			alchemy_window.spinner = spinner;
		},
		onComplete: function () {
			alchemy_window.spinner.remove();
		}
	});
	if (overflow == 'true') {
		alchemy_window.getContent().setStyle({overflow: 'visible'});
		alchemy_window.getContent().up().setStyle({overflow: 'visible'});
	};
	alchemy_window.showCenter(modal == 'true' ? 'modal' : null);
}

function zoomImage(url, title, width, height) {
	var window_height = height;
	var window_width = width;
	if (width > document.viewport.getWidth()) {
		window_width = document.viewport.getWidth() - 50;
	}
	if (height > document.viewport.getHeight()) {
		window_height = document.viewport.getHeight() - 100;
	}
	image_window = new Window({
		className: "alchemy_window",
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
		},
		onClose: function () {
			delete window.image_window;
		}
	});
	image_window.showCenter();
}

function openLinkWindow(selElem, width) {
	link_window = new Window({
		className: "alchemy_window",
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
	link_window.tinyMCE = {}
	link_window.tinyMCE = {
		editorInstance: selElem,
		selectionBookmark: selElem.selection ? selElem.selection.getBookmark() : null
	};
	link_window.setAjaxContent('/admin/pages/link', {method: 'get'});
	link_window.showCenter('modal');
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

function pleaseWaitOverlay(show) {
	if (typeof(show) == 'undefined') {
		show = true;
	}
	var overlay = $('overlay');
	if (overlay)
		overlay.style.visibility = show ? 'visible' : 'hidden';
}

function isIe() {
	return typeof document.all == 'object';
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
	preview_window.refresh();
}

function alchemyListFilter(selector){
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
	$$('.link_window_tab_body').invoke('hide');
	$$('.link_window_tab').invoke('removeClassName', 'active');
}

function showLinkWindowTab (id, tab) {
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
	$('assign_file_' + selected_element).addClassName('selected_file');
}

function alchemyUnlink (ed) {
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

function removePictureLink (content_id) {
	$('content_'+content_id+'_link').value='';
	$('content_'+content_id+'_link_title').value='';
	$('content_'+content_id+'_link_class_name').value='';
	$('content_'+content_id+'_link_target').value='';
	$('edit_link_'+content_id).removeClassName('linked');
}

function alchemyCreateLink(link_type, url, title, extern) { 
	var tiny_ed = link_window.tinyMCE.editorInstance;
	if (tiny_ed.selection) {
			// aka we are linking text inside of TinyMCE 
			// var bm = link_window.tinyMCE.selectionBookmark;
			// tiny_ed.selection.moveToBookmark(bm);
			var l = tiny_ed.execCommand('mceInsertLink', false, {
				href: url,
				'class': link_type,
				title: title,
				target: (extern ? '_blank' : null)
			});
	} else {
		// aka: we are linking an content
		var essence_type = tiny_ed.name.gsub('essence_', '').split('_')[0];
		switch (essence_type) {
			case "picture":
				var content_id = tiny_ed.name.gsub('essence_picture_', '');
				break;
			case "text":
				var content_id = tiny_ed.name.gsub('content_text_', '');
				break;
		}
		$('content_' + content_id + '_link').value = url;
		$('content_' + content_id + '_link_title').value = title;
		$('content_' + content_id + '_link_class_name').value = link_type;
		$('content_' + content_id + '_link_target').value = (extern ? '1' : '0');
	}
}

// creates a link to a javascript function
function alchemyCreateLinkToFunction(link_type, func, title) { 
	var tiny_ed = link_window.tinyMCE.editorInstance;
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
function selectLinkWindowTab() {
	var tiny_ed = link_window.tinyMCE.editorInstance;
	if (typeof(tiny_ed.selection) == 'undefined') {
		var tmp_link = document.createElement("a");
		var selection = tiny_ed;
		var essence_type = tiny_ed.name.gsub('essence_', '').split('_')[0];
		switch (essence_type) {
			case "picture":
				var content_id = tiny_ed.name.gsub('essence_picture_', '');
				break;
			case "text":
				var content_id = tiny_ed.name.gsub('essence_text_', '');
				break;
		}
		tmp_link.href = $('content_' + content_id + '_link').value;
		tmp_link.title = $('content_' + content_id + '_link_title').value;
		tmp_link.target = ($('content_' + content_id + '_link_target').value == '1' ? '_blank' : '');
		tmp_link.className = $('content_' + content_id + '_link_class_name').value;
		var link = tmp_link;
	} else {
		var bm = link_window.tinyMCE.selectionBookmark;
		tiny_ed.selection.moveToBookmark(bm);
		var link = tiny_ed.selection.getNode();
	}
	if (link.nodeName == "A") {
		var title = link.title == null ? "" : link.title;
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
				// select the line where the link was detected in.
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
							// sadly this does not work here. maybe later i have the knowledge to fix this.
							var select = AlchemySelectbox.findSelectById(alchemy_selectbox.id);
							select.fire('alchemy_selectbox:select', {value: '#' + internal_anchor});
						}
					});
				}
			}
		}
		if ( link.className == 'external' ) {
			showLinkWindowTab('sitemap_external_links', $('tab_for_sitemap_external_links'));
			protocols = $('url_protocol_select').select('.alchemy_selectbox_body a').pluck('rel');
			protocols.each(function(p) {
				if ( link.href.startsWith(p) ) {
					$('external_url').value = link.href.gsub(p, "");
					$('url_protocol_select').fire('alchemy_selectbox:select', {value: p});
					$('extern_link_title').value = title;
					$('link_target').checked = (link.target == "_blank");
				}
			});
		}
		if ( link.className == 'file' ) {
			showLinkWindowTab('file_links', $('tab_for_file_links'));
			$('file_link_title').value = title;
			$('public_filename_select').fire('alchemy_selectbox:select', {value: link.pathname});
			$('file_link_target').checked = link.target == "_blank";
		}
		if ( link.className == 'contact' ) {
			var link_url = link.pathname;
			var link_params = link.href.split('?')[1];
			var link_subject = link_params.split('&')[0];
			var link_mailto = link_params.split('&')[1];
			var link_body = link_params.split('&')[2];
			showLinkWindowTab('contactform_links', $('tab_for_contactform_links'));
			$('contactform_link_title').value = title;
			$('contactform_url').value = link_url;
			$('contactform_subject').value = unescape(link_subject.gsub(/subject=/,''));
			$('contactform_body').value = unescape(link_body.gsub(/body=/,''));
			$('contactform_mailto').value = link_mailto.gsub(/mail_to=/,'');
		}
	}
}

function showElementsFromPageSelector (id) {
	$('elements_for_page_' + id).show();
	page_select_scrollbar.scrollTo($('sitemap_sitename_' + id));
	page_select_scrollbar.recalculateLayout();
}

function hideElementsFromPageSelector (id) {
	$('elements_for_page_' + id).hide();
	$('page_anchor').removeAttribute('value');
	page_select_scrollbar.scrollTo($('sitemap_sitename_' + id));
	page_select_scrollbar.recalculateLayout();
}

function alchemyImageFade(image) {
	try {
		image.up().up().previous().hide();
		image.up().up().appear({duration: 0.6});
	} catch(e){};
}

// Used for saving the richtext essence from tinymce.
function saveRichtextEssences (element_id) {
	var element = $('element_'+element_id);
	if (element) {
		var richtext_essences = element.select('textarea.tinymce');
		richtext_essences.each(function (essence) {
			var editor = tinyMCE.get(essence.id);
			var content = editor.getContent();
			$(editor.editorId).value = content;
			//removing the editor instance before adding it dynamically after saving
			$(editor.editorId).previous('div.essence_richtext_loader').show();
			tinyMCE.execCommand(
				'mceRemoveControl',
				true,
				editor.editorId
			);
		});
	}
}

function createSortableTree () {
	var tree = new SortableTree(
		$('sitemap'),
		{
			draggable: {
				ghosting: true,
				reverting: true,
				handle: 'handle',
				scroll: window,
				starteffect: function (element) {
					new Effect.Opacity(element, {
						from: 1.0, to: 0.2, duration: 0.2
					});
				}
			},
			onDrop: function(drag, drop, event) {
				pleaseWaitOverlay();
				new Ajax.Request(
					'/admin/pages/move',
					{
						postBody: drag.to_params(),
						onComplete: function () {
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
