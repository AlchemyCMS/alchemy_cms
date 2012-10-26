if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {

  var ElementsWindow = {};
  $.extend(Alchemy, ElementsWindow);

  Alchemy.ElementsWindow = {

    init: function(path, options, callback) {
      var self = Alchemy.ElementsWindow;
      var $dialog = $('<div style="display: none" id="alchemyElementWindow"></div>');
      var closeCallback = function() {
          $dialog.dialog("destroy");
          $('#alchemyElementWindow').remove();
          Alchemy.ElementsWindow.button.enable();
        };
      self.path = path;
      self.callback = callback;
      $dialog.html(Alchemy.getOverlaySpinner({
        x: 420,
        y: 300
      }));
      self.dialog = $dialog;
      Alchemy.ElementsWindow.currentWindow = $dialog.dialog({
        modal: false,
        minWidth: 422,
        minHeight: 300,
        height: $(window).height() - 90,
        title: options.texts.title,
        show: "fade",
        hide: "fade",
        position: [$(window).width() - 428, 84],
        closeOnEscape: false,
        create: function() {
          $dialog.before(Alchemy.ElementsWindow.createToolbar(options.toolbarButtons));
        },
        open: function(event, ui) {
          Alchemy.ElementsWindow.button.disable();
          Alchemy.ElementsWindow.reload(callback);
        },
        beforeClose: function() {
          if (Alchemy.isPageDirty()) {
            Alchemy.openConfirmWindow({
              title: options.texts.dirtyTitle,
              message: options.texts.dirtyMessage,
              okLabel: options.texts.okLabel,
              cancelLabel: options.texts.cancelLabel,
              okCallback: closeCallback
            });
            return false;
          } else {
            return true;
          }
        },
        close: closeCallback
      });
    },

    button: {
      enable: function() {
        $('div#show_element_window').
          removeClass('disabled').
          find('a').removeAttr('tabindex');
      },
      disable: function() {
        $('div#show_element_window').
          addClass('disabled').
          find('a').attr('tabindex', '-1');
      },
      toggle: function() {
        if ($('div#show_element_window').hasClass('disabled')) {
          Alchemy.ElementsWindow.button.enable();
        } else {
          Alchemy.ElementsWindow.button.disable();
        }
      }
    },

    createToolbar: function(buttons) {
      var $toolbar = $('<div id="overlay_toolbar"></div>'),
        btn;
      for (i = 0; i < buttons.length; i++) {
        btn = buttons[i];
        $toolbar.append(
        Alchemy.ToolbarButton({
          buttonTitle: btn.title,
          buttonLabel: btn.label,
          iconClass: btn.iconClass,
          onClick: btn.onClick,
          buttonId: btn.buttonId
        }));
      }
      return $toolbar;
    },

    reload: function() {
      var self = Alchemy.ElementsWindow;
      $.ajax({
        url: self.path,
        success: function(data, textStatus, XMLHttpRequest) {
          self.dialog.html(data);
          Alchemy.Buttons.observe('#alchemyElementWindow');
          Alchemy.overlayObserver('#alchemyElementWindow');
          Alchemy.Datepicker('#alchemyElementWindow input.date, #alchemyElementWindow input[type="date"]');
          if (self.callback) {
            self.callback.call();
          }
        },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown);
        }
      });
    }

  }

})(jQuery);
