if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {

  // Setting jQueryUIs global animation duration
  $.fx.speeds._default = 400;

  // The Alchemy JavaScript Object contains all Functions
  $.extend(Alchemy, {

    pictureSelector: function() {
      var
        $selected_item_tools = $('.selected_item_tools'),
        $picture_selects = $('.picture_tool.select input');
      $picture_selects.on('change', function() {
        if ($picture_selects.filter(':checked').size() > 0) {
          $selected_item_tools.show();
        } else {
          $selected_item_tools.hide();
        }
        if (this.checked) {
          $(this).parent().addClass('visible').removeClass('hidden');
        } else {
          $(this).parent().removeClass('visible').addClass('hidden');
        }
      });
      $('a#edit_multiple_pictures').on('click', function(e) {
        var
          $this = $(this),
          picture_ids = $("input:checkbox", '#picture_archive').serialize();
        e.preventDefault();
        Alchemy.openWindow(
          $this.attr('href') + '?' + picture_ids,
          $this.attr('title'),
          400,
          230,
          false,
          true,
          false
        );
        return false;
      });
    },

    pleaseWaitOverlay: function(show) {
      if (typeof(show) == 'undefined') {
        show = true;
      }
      var $overlay = $('#overlay');
      $overlay.css("visibility", show ? 'visible' : 'hidden');
    },

    toggleElement: function(id, url, token, text) {
      var toggle = function() {
          $('#element_' + id + '_folder').hide();
          $('#element_' + id + '_folder_spinner').show();
          $.post(url, {
            authenticity_token: encodeURIComponent(token)
          }, function(request) {
            $('#element_' + id + '_folder').show();
            $('#element_' + id + '_folder_spinner').hide();
          });
        }
      if (Alchemy.isPageDirty()) {
        Alchemy.openConfirmWindow({
          title: text.title,
          message: text.message,
          okLabel: text.okLabel,
          cancelLabel: text.cancelLabel,
          okCallback: toggle
        });
        return false;
      } else {
        toggle();
      }
    },

    ListFilter: function(selector) {
      var text = $('#search_field').val().toLowerCase();
      var $boxes = $(selector);
      $boxes.map(function() {
        $this = $(this);
        $this.css({
          display: $this.attr('name').toLowerCase().indexOf(text) != -1 ? '' : 'none'
        });
      });
    },

    fadeImage: function(image, spinner_selector) {
      try {
        $(spinner_selector).hide();
        $(image).fadeIn(600);
      } catch (e) {
        Alchemy.debug(e);
      };
    },

    removePicture: function(selector) {
      var $form_field = $(selector);
      var $element = $form_field.parents('.element_editor');
      if ($form_field) {
        $form_field.val('');
        $form_field.prev().remove();
        $form_field.parent().addClass('missing');
        Alchemy.setElementDirty($element);
      }
    },

    setElementSaved: function(selector) {
      var $element = $(selector);
      Alchemy.setElementClean(selector);
      Alchemy.Buttons.enable($element);
    },

    SelectBox: function(scope) {
      $('select.alchemy_selectbox', scope).selectBoxIt();
    },

    Buttons: function(options) {
      $("button, input:submit, a.button").button(options);
    },

    selectOrCreateCellTab: function(cell_name, label) {
      if ($('#cell_' + cell_name).size() === 0) {
        $('#cells').tabs('add', '#cell_' + cell_name, label);
        $('#cell_' + cell_name).addClass('sortable_cell');
      }
      $('#cells').tabs('select', 'cell_' + cell_name);
    },

    buildTabbedCells: function(label) {
      var $cells = $('<div id="cells"/>');
      $('#cell_for_other_elements').wrap($cells);
      $('#cells').prepend('<ul><li><a href="#cell_for_other_elements">'+label+'</a></li></ul>');
      $('#cells').tabs().tabs('paging', { follow: true, followOnSelect: true } );
    },

    debug: function(e) {
      if (window['console']) {
        console.debug(e);
        console.trace();
      }
    },

    getUrlParam: function(name) {
      var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
      if (results) return results[1] || 0;
    },

    isiPhone: navigator.userAgent.match(/iPhone/i) !== null,
    isiPad: navigator.userAgent.match(/iPad/i) !== null,
    isiPod: navigator.userAgent.match(/iPod/i) !== null,
    isiOS: navigator.userAgent.match(/iPad|iPhone|iPod/i) !== null,
    isFirefox: navigator.userAgent.match(/Firefox/i) !== null,
    isChrome: navigator.userAgent.match(/Chrome/i) !== null,
    isSafari: navigator.userAgent.match(/Safari/i) !== null,
    isIE: navigator.userAgent.match(/MSIE/i) !== null

  });

  Alchemy.getBrowserVersion = function(browser) {
    return Alchemy['is' + browser] ? parseInt(navigator.userAgent.match(new RegExp(browser + ".[0-9]+", 'i'))[0].replace(new RegExp(browser + '.'), ''), 10) : null;
  }

  Alchemy.ChromeVersion = Alchemy.getBrowserVersion('Chrome');
  Alchemy.FirefoxVersion = Alchemy.getBrowserVersion('Firefox');
  Alchemy.SafariVersion = Alchemy.getBrowserVersion('Safari');
  Alchemy.IEVersion = Alchemy.getBrowserVersion('MSIE');

})(jQuery);
