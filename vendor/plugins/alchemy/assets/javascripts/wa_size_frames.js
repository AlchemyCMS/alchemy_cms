var LEFT_SIZE = 400;
var TOP_SIZE = 46;
var SHRINKED_TOP_SIZE = 0;
var SHRINKED_LEFT_SIZE = 0;
var BORDER_WIDTH = 1;
var TOP_ID = "top_frame";
var LEFT_ID = "left_frame";
var is_ie = (document.all) ? true : false;

function setDivStati() {
    var top_status = getCookie(TOP_ID) == "true";
    var left_status = getCookie(LEFT_ID) == "true";
    setSize($(TOP_ID), 'height', top_status);
    setSize($(LEFT_ID), 'width', left_status);
}

function setFrameSize() {
    var frame = $('iframe');
    if (frame) {
        var browser_height = document.viewport.getHeight() - $(TOP_ID).getHeight();
        var left = $(LEFT_ID);
        setLeftHeight();
        var width = document.viewport.getWidth() - $(LEFT_ID).getWidth() - BORDER_WIDTH;
        var left_height = left.getHeight();
        if (left_height <= browser_height) {
            frame.setStyle({
                height: browser_height - BORDER_WIDTH - TOP_SIZE + 'px',
                width: width + 'px'
            });
        }
        else if (left_height >= browser_height) {
            frame.setStyle({
                height: left_height - TOP_SIZE - BORDER_WIDTH + 'px',
                width: width + 'px'
            });
        }
        else {
            frame.setStyle({
                height: browser_height - BORDER_WIDTH - TOP_SIZE + 'px',
                width: width + 'px'
            });
        }
    }
    positionFrame();
}

// needless since we do not get the body onload event from frame.document
function frameBodySize() {
    var frame = $('iframe');
    var frame_body = null;
    if (is_ie) {
        frame_body = frame.contentWindow.document.body;
    } else {
        frame_body = frame.contentDocument.getElementsByTagName('body')[0];
    }
    var height = frame_body.offsetHeight;
    return height;
}

function positionFrame() {
    var preview = $('preview');
    var top = $(TOP_ID).getHeight();
    var left = $(LEFT_ID).getWidth();
    if (preview) {
        preview.setStyle({
            top: top + 'px',
            left: left + 'px'
        });
    }
}

function setLeftHeight() {
    var left = $(LEFT_ID);
    if ($('wa_main_content') && $('preview') && left) {
        var left_height = $('wa_main_content').getHeight();
        var browser_height = document.viewport.getHeight();
        if (browser_height >= left_height) {
            var height = browser_height;
        } else {
            var height = left_height;
        }
        if (left) {
            left.setStyle({
                height: height + "px"
            });
        }
    }
}

function switchDiv(frame_id) {
    var f = $(frame_id);
    if (f) {
        if (frame_id == TOP_ID) {
            var status = f.getHeight() == TOP_SIZE;
            setSize(f, 'height', status);
            setCookie(frame_id, status.toString());
        } else {
            var status = f.getWidth() == LEFT_SIZE;
            setSize(f, 'width', status);
            setCookie(frame_id, status.toString());
        }
    }
    setFrameSize();
}

function setSize(element, style, status) {
    var element = $(element);
    if (element) {
        if (style == "width") {
            var size = status ? SHRINKED_LEFT_SIZE: LEFT_SIZE;
            element.setStyle({
                width: size + "px"
            });
        } else {
            var size = status ? SHRINKED_TOP_SIZE: TOP_SIZE;
            element.setStyle({
                height: size + "px"
            });
        }
        status ? element.hide() : element.show();
        switchImage(element, status);
    }
}

function switchImage(element, status) {
    var new_status = status ? "open": "close";
    var old_status = !status ? "open": "close";
    if ($(element.id + "_switch"))
    var img = $(element.id + "_switch").firstDescendant();
    if (img)
    img.src = img.src.replace(old_status, new_status);
}

function getStatus(element) {
    var status = f.getWidth() == SHRINKED_LEFT_SIZE ? "True": "False";
    return status == "True";
}

function getCookie(name) {
    var aCookie = document.cookie.split("; ");
    for (var i = 0; i < aCookie.length; i++) {
        var aCrumb = aCookie[i].split("=");
        if (name == aCrumb[0])
        return unescape(aCrumb[1]);
    }
    return null;
}

function setCookie(name, value) {
    document.cookie = name + "=" + escape(value) + "; ";
}

function delCookie(name) {
    document.cookie = name + "=" + escape(value) + "; expires=Fri, 31 Dec 1999 23:59:59 GMT;";
}
