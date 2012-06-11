// Testing for HTML5 features
if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

Alchemy.HTML5 = {};

Alchemy.HTML5.hasUploadSupport = function() {
  return typeof(window.FileReader) !== 'undefined' && supportFileAPI() && supportAjaxUploadProgressEvents();

  function supportFileAPI() {
    var fi = document.createElement('INPUT');
    fi.type = 'file';
    return 'files' in fi;
  }

  function supportAjaxUploadProgressEvents() {
    var xhr = new XMLHttpRequest();
    return !!(xhr && ('upload' in xhr) && ('onprogress' in xhr.upload));
  }

};
