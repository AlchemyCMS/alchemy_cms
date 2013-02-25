if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {

  var PreviewWindow = {};
  $.extend(Alchemy, PreviewWindow);

  Alchemy.PreviewWindow = {

    init: function(url, title) {
      var $iframe = $('#alchemyPreviewWindow');
      if ($iframe.length === 0) {
        $iframe = $('<iframe src="' + url + '" id="alchemyPreviewWindow" frameborder="0"></iframe>');
        $iframe.load(function() {
          $('.preview-refresh-spinner').hide();
        });
        $iframe.css({
          'background-color': '#ffffff'
        });
        Alchemy.PreviewWindow.currentWindow = $iframe.dialog({
          modal: false,
          title: title,
          width: $(window).width() - 502,
          height: $(window).height() - 76,
          minWidth: 600,
          minHeight: 300,
          show: "fade",
          hide: "fade",
          position: [70, 84],
          autoResize: true,
          closeOnEscape: false,
          create: function() {
            var spinner = Alchemy.Spinner.small({className: 'preview-refresh-spinner'});
            var $reload = $('<a href="#" class="ui-dialog-titlebar-refresh ui-corner-all" role="button"></a>');
            var $titlebar = $('#alchemyPreviewWindow').prev();
            $reload.append('<span class="ui-icon ui-icon-refresh">reload</span>');
            $titlebar.append($reload);
            $titlebar.append(spinner.spin().el);
            $reload.click(Alchemy.reloadPreview);
          },
          close: function(event, ui) {
            Alchemy.PreviewWindow.button.enable();
          },
          open: function(event, ui) {
            $(this).css({
              width: '100%'
            });
            Alchemy.PreviewWindow.button.disable();
          }
        }).dialogExtend({
          "maximize": true,
          "dblclick": "maximize",
          "icons" : {
            "maximize" : "ui-icon-fullscreen",
            "restore" : "ui-icon-exit-fullscreen"
          }
        });
      } else {
        $('#alchemyPreviewWindow').dialog('open');
      }
    },

    refresh: function() {
      var $iframe = $('#alchemyPreviewWindow');
      $('.preview-refresh-spinner').show();
      $iframe.load(function() {
        $('.preview-refresh-spinner').hide();
      });
      $iframe.attr('src', $iframe.attr('src'));
      return true;
    },

    button: {
      enable: function() {
        $('div#show_preview_window').
          removeClass('disabled').
          find('a').removeAttr('tabindex');
      },
      disable: function() {
        $('div#show_preview_window').
          addClass('disabled').
          find('a').attr('tabindex', '-1');
      },
      toggle: function() {
        if ($('div#show_preview_window').hasClass('disabled')) {
          Alchemy.PreviewWindow.button.enable();
        } else {
          Alchemy.PreviewWindow.button.disable();
        }
      }
    },

  };

  Alchemy.reloadPreview = function() {
    Alchemy.PreviewWindow.refresh();
  };

})(jQuery);
