if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {
  
  var Growler = {};
  $.extend(Alchemy, Growler);
  
  Alchemy.Growler = {
    
    build : function(message, flash_type) {
      var $flash_container = $('<div class="flash '+flash_type+'" />');
      var icon_class = flash_type === 'notice' ? 'tick' : 'error';
      $flash_container.append('<span class="icon '+icon_class+'" />');
      $flash_container.append(message);
      $('#flash_notices').append($flash_container);
      $('#flash_notices').show();
      Alchemy.Growler.fade();
    },
    
    fade : function() {
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
    }
    
  },
  
  Alchemy.growl = function(message, style) {
    if (typeof(style) === 'undefined') {
      style = 'notice';
    }
    Alchemy.Growler.build(message, style);
  }
  
})(jQuery);
