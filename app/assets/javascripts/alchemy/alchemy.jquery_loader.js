if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

// Load jQuery on demand. Use this if jQuery is not present.
// Found on http://css-tricks.com/snippets/jquery/load-jquery-only-if-not-present/
Alchemy.loadjQuery = function(callback) {

  var thisPageUsingOtherJSLibrary = false;

  if (typeof($) === 'function') {
    thisPageUsingOtherJSLibrary = true;
  }

  function getScript(url, success) {
    var script = document.createElement('script');
    var head = document.getElementsByTagName('head')[0],
      done = false;
    script.src = url;
    // Attach handlers for all browsers
    script.onload = script.onreadystatechange = function() {
      if (!done && (!this.readyState || this.readyState === 'loaded' || this.readyState === 'complete')) {
        done = true;
        // callback function provided as param
        success();
        script.onload = script.onreadystatechange = null;
        head.removeChild(script);
      };
    };
    head.appendChild(script);
  }

  getScript('//code.jquery.com/jquery.min.js', function() {
    if (typeof(jQuery) !== 'undefined') {
      if (thisPageUsingOtherJSLibrary) {
        jQuery.noConflict();
      }
      callback(jQuery);
    }
  });

}
