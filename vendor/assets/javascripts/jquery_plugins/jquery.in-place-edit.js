/*
* jquery-in-place-edit plugin
*
* Copyright (c) 2008 Christian Hellsten
*
* Plugin homepage:
*  http://aktagon.com/projects/jquery/in-place-edit/
*  http://github.com/christianhellsten/jquery-in-place-edit/
*
* Examples:
*  http://aktagon.com/projects/jquery/in-place-edit/examples/
*
* Repository:
*  git://github.com/christianhellsten/jquery-in-place-edit.git
*
* Version 1.0.2
*
* Tested with:
*  Windows:  Firefox 2, Firefox 3, Internet Explorer 6, Internet Explorer 7
*  Linux:    Firefox 2, Firefox 3, Opera
*  Mac:      Firefox 2, Firefox 3, Opera
*
*
* Licensed under the MIT license:
* http://www.opensource.org/licenses/mit-license.php
*
*/
(function($) {
 
  $.fn.inPlaceEdit = function(options) {
 
    // Add click handler to all matching elements
    return this.each(function() {
      // Use default options, if necessary
      var settings = $.extend({}, $.fn.inPlaceEdit.defaults, options);
 
      var element = $(this);
 
      element.click(function() {
        element.data('skipBlur', false)
 
        // Prevent multiple clicks, and check if inplace editing is disabled
        if (element.hasClass("editing") || element.hasClass("disabled")) {
            return;
        }
 
        element.addClass("editing");
 
        element.old_value = element.html();          // Store old HTML so we can revert to it later
 
        if(typeof(settings.html) == 'string') {     // There are two types of form templates: strings and DOM elements
          element.html(settings.html);              // Replace current HTML with given HTML
        }
        else {
          element.html('');                         // Replace current HTML with given object's HTML
          var form_template = settings.html.children(':first').clone(true);
          form_template.appendTo(element);          // Clone event handlers too
        }
 
        $('.field', element).val(element.old_value); // Set field value to old HTML
        $('.field', element).focus();               // Set focus to input field
        $('.field', element).select();              // Select all text in field
 
        // On blur: cancel action
        if(settings.onBlurDisabled == false) {
          $('.field', element).blur(function() {
            // Prevent cancel from being triggered when clicking Save & Cancel button
            var skipBlur = element.data('skipBlur')
 
            if(skipBlur != true) {
              element.timeout = setTimeout(cancel, 50);
            }
 
            element.data('skipBlur', false)
          });
        }
 
        // On save: revert to old HTML and submit
        $('.save-button', element).click(function() {
          return submit();
        });
 
        $('.save-button', element).mousedown(function() {
          element.data('skipBlur', true)
        });
 
        $('.cancel-button', element).mousedown(function() {
          element.data('skipBlur', true)
        });
 
        // On cancel: revert to old HTML
        $('.cancel-button', element).click(function() {
          return cancel();
        });
 
        // On keyup: submit (ESC) or cancel (enter)
        if(settings.onKeyupDisabled == false) {
          $('.field', element).keyup(function(event) {
            var keycode = event.which;
            var type = this.tagName.toLowerCase();
 
            if(keycode == 27 && settings.escapeKeyDisabled == false)  {      // escape
              return cancel();
            }
            else if(keycode == 13) { // enter
              // Don't submit on enter if this is a textarea
              if(type != "textarea") {
                return submit();
              }
            }
            return true;
          });
        }
      });
 
      // Add hover class on mouseover
      element.mouseover(function() {
        element.addClass("hover");
      });
 
      // Remove hover class on mouseout
      element.mouseout(function() {
        element.removeClass("hover");
      });
 
      function cancel() {
        element.html(element.old_value);
 
        element.removeClass("hover editing");
 
        if(options.cancel) {
          options.cancel.apply(element, [element]);
        }
        return false; // Stop propagation
      };
 
      function submit() {
        clearTimeout(element.timeout);
 
        var id = element.attr('id');
        var value = $('.field', element).val();
 
        if(options.submit) {
          options.submit.apply(element, [element, id, value, element.old_value]);
        }
 
        element.removeClass("hover editing");
 
        element.html(value);
 
        return false; // Stop propagation
      };
    });
 
  };
 
  // Default (overridable) settings
  $.fn.inPlaceEdit.defaults = {
    onBlurDisabled  : false,
    onKeyupDisabled : false,
    escapeKeyDisabled : false,
    html : ' \
          <div class="inplace-edit"> \
            <input type="text" value="" class="field" /> \
            <div class="buttons"> \
              <input type="button" value="Save" class="save-button" /> \
              <input type="button" value="Cancel" class="cancel-button" /> \
            </div> \
          </div>'
  };
})(jQuery);
