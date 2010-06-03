function parseInternalLink(area_name, page_name, href, atom_id, url_prefix) {
    href = (url_prefix == null ? '/' + href : url_prefix + href);
    var link_title = $('internal_link_title').value;
    if (area_name == "") {
        save_atom(atom_id, href, link_title, false);
    }
    else if (area_name == "wa_atom_text") {
        set_atom_content('wa_atom_' + atom_id + '_link_and_title', href, link_title);
    }
    else {
        e = getFrameWindow(area_name);
        a = e.document.createElement('a');
        a.href = href;
        a.innerHTML = e.getSelection();
        if (link_title.length == 0)
        link_title = page_name;
        a.setAttribute("title", link_title);
        insertNodeAtSelection(e, a);
    }
}

function parseExternalLink(area_name, atom_id, url_prefix)
{
    // TODO: we have to put the url_prefix for the href and send the href as url paramter to the recipients controller
    var link_to_value = $('link_to_value').value;
    var link_to_protocol = $('link_to_protocol').value;
    var link_target = $('link_target').checked;
    var link_title = $('extern_link_title').value;
    var href = link_to_protocol + link_to_value;

    if (link_title.length == 0) {
        link_title = (link_target ? href + " in einem neuen Fenster öffnen": href);
    }
    if (area_name == "") {
        save_atom(atom_id, href, link_title, link_target);
    }
    else if (area_name == "wa_atom_text") {
        set_atom_content('wa_atom_' + atom_id + '_link_and_title', href, link_title);
    }
    else {
        e = getFrameWindow(area_name);
        a = e.document.createElement('a');
        a.href = href;
        a.innerHTML = e.getSelection();
        if (link_target) {
            a.setAttribute("target", "_blank");
        }
        a.setAttribute("title", link_title);
        a.addClassName("external_link");
        insertNodeAtSelection(e, a);
    }
}

function parseFileLink(area_name, file_path, file_name, atom_id, url_prefix, new_window) {
    file_path = (url_prefix == null ? file_path : url_prefix + file_path);
    var link_title = $('file_link_title').value;
    if (area_name == "") {
        save_atom(atom_id, file_path, link_title, false);
    }
    else if (area_name == "wa_atom_text") {
        set_atom_content('wa_atom_' + atom_id + '_link_and_title', file_path, link_title);
    }
    else {
        e = getFrameWindow(area_name);
        a = e.document.createElement('a');
        a.href = file_path;
        a.innerHTML = e.getSelection();
        if (link_title.length == 0)
        link_title = "Die Datei '" + file_name + "' öffnen.";
        a.setAttribute("title", link_title);
        if (new_window) {
            a.setAttribute("target", "_blank");
        }
        a.setAttribute
        a.addClassName("file_link");
        insertNodeAtSelection(e, a);
    }
}

function save_atom(atom_id, link, title, link_target) {
    new Ajax.Request(
        '/wa_atom_pictures/save_link/' + atom_id + '?link=' + link + '&title=' + title + '&blank=' + link_target, {
            asynchronous: true,
            evalScripts: true
        }
    );
}

function set_atom_content(dom_id, link, title) {
    var container = $(dom_id);
    container.down('input.wa_atom_text_link', 0).value = link;
    container.down('input.wa_atom_text_title', 0).value = title;
}
