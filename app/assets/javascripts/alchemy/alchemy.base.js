if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {

  // Setting jQueryUIs global animation duration
  $.fx.speeds._default = 400;

  // The Alchemy JavaScript Object contains all Functions
  $.extend(Alchemy, {

    inPlaceEditor: function(options) {
      var defaults = {
        save_label: 'save',
        cancel_label: 'cancel'
      };
      var settings = jQuery.extend({}, defaults, options);
      var cancel_handler = function(element) {
        jQuery(element).css({
          overflow: 'hidden'
        });
        return true;
      };
      var submit_handler = function(element, id, value) {
        $(element).css({
          overflow: 'hidden'
        });
        id = id.match(/\d+/)[0];
        $.ajax({
          url: Alchemy.routes.admin_picture_path(id),
          type: 'PUT',
          data: {
            'picture[name]': value,
            size: Alchemy.getUrlParam('size')
          }
        });
        return false;
      };

      $('#alchemy .rename').click(function() {
        $(this).css({
          overflow: 'visible'
        });
      });

      $('#alchemy .rename').inPlaceEdit({
        submit: submit_handler,
        cancel: cancel_handler,
        html: ' \
                <div class="inplace-edit"> \
                  <input type="text" value="" class="thin_border field" /> \
                  <div class="buttons"> \
                    <input type="button" value="' + settings.save_label + '" class="save-button button" /> \
                    <input type="button" value="' + settings.cancel_label + '" class="cancel-button button" /> \
                  </div> \
                </div>'
      });

    },

    pictureSelector: function() {
      var
        $selected_item_tools = $('.selected_item_tools'),
        $picture_selects = $('.picture_tool.select input');
      $picture_selects.on('click', function() {
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
      Alchemy.enableButton('button.button', $element);
    },

    resizeFrame: function() {
      var options = {
        left: 65,
        right: 0
      };
      var $mainFrame = $('#main_content');
      var $topFrame = $('#top_menu');
      var view_height = $(window).height();
      var view_width = $(window).width();
      var topFrameHeight = $topFrame.height();
      var mainFrameHeight = view_height - topFrameHeight;
      var width = view_width - options.left - options.right;
      if ($mainFrame.length > 0) {
        $mainFrame.css({
          top: topFrameHeight,
          width: width,
          height: mainFrameHeight
        });
      }
      if ($topFrame.length > 0) {
        $topFrame.css({
          width: width,
          height: topFrameHeight
        });
      }
    },

    Tooltips: function() {
      var xOffset = 10;
      var yOffset = 20;
      $(".tooltip").hover(function(e) {
        this.original_title = this.title;
        if (this.original_title == '') {
          this.tooltip_content = $(this).next('.tooltip_content').html();
        } else {
          this.tooltip_content = this.original_title;
        }
        if (this.tooltip_content != null) {
          this.title = "";
          $("body").append("<div id='tooltip'>" + this.tooltip_content + "</div>");
          $("#tooltip").css("top", (e.pageY - xOffset) + "px").css("left", (e.pageX + yOffset) + "px").fadeIn(400);
        }
      }, function() {
        this.title = this.original_title;
        $("#tooltip").remove();
      });
      $(".tooltip").mousemove(function(e) {
        $("#tooltip").css("top", (e.pageY - xOffset) + "px").css("left", (e.pageX + yOffset) + "px");
      });
    },

    SelectBox: function(scope) {
      $('select', scope).selectBoxIt();
    },

    Buttons: function(options) {
      $("button, input:submit, a.button").button(options);
    },

    handleEssenceCheckbox: function(checkbox) {
      var $checkbox = $(checkbox);
      if (checkbox.checked) {
        $('#' + checkbox.id + '_hidden').remove();
      } else {
        $checkbox.after('<input type="hidden" value="0" name="' + checkbox.name + '" id="' + checkbox.id + '_hidden">');
      }
    },

    selectOrCreateCellTab: function(cell_name, label) {
      if ($('#cell_' + cell_name).size() === 0) {
        $('#cells').tabs('add', '#cell_' + cell_name, label);
        $('#cell_' + cell_name).addClass('sortable_cell');
      }
      $('#cells').tabs('select', 'cell_' + cell_name);
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
    isIE: navigator.userAgent.match(/MSIE/i) !== null,

    locale: 'en'

  });

  Alchemy.getBrowserVersion = function(browser) {
    return Alchemy['is' + browser] ? parseInt(navigator.userAgent.match(new RegExp(browser + ".[0-9]+", 'i'))[0].replace(new RegExp(browser + '.'), ''), 10) : null;
  }

  Alchemy.ChromeVersion = Alchemy.getBrowserVersion('Chrome');
  Alchemy.FirefoxVersion = Alchemy.getBrowserVersion('Firefox');
  Alchemy.SafariVersion = Alchemy.getBrowserVersion('Safari');
  Alchemy.IEVersion = Alchemy.getBrowserVersion('MSIE');

})(jQuery);
