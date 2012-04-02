if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

Alchemy.initAlchemyPreviewMode = function () {

  // Setting jQueryUIs global animation duration
  $.fx.speeds._default = 400;

  // The Alchemy JavaScript Object contains all Functions
  $.extend(Alchemy, {

    ElementSelector:{

      // defaults
      styles:{
        reset:{ outline:'0 none' },
        hover:{
          'outline-width':'2px',
          'outline-style':'solid',
          'outline-color':'#98BAD5',
          'outline-offset':'4px',
          '-moz-outline-radius':'4px',
          'outline-radius':'4px'
        },
        selected:{
          'outline-width':'2px',
          'outline-style':'solid',
          'outline-color':'#DB694C',
          'outline-offset':'4px',
          '-moz-outline-radius':'4px',
          'outline-radius':'4px'
        }
      },

      scrollOffset:20,

      init:function () {
        var self = Alchemy.ElementSelector;
        var $elements = $('[data-alchemy-element]');
        var styles = self.styles;
        $elements.bind('mouseover', function (e) {
          $(this).attr('title', 'Klicken zum bearbeiten');
          if (!$(this).hasClass('selected'))
            $(this).css(styles.hover);
        });
        $elements.bind('mouseout', function () {
          $(this).removeAttr('title');
          if (!$(this).hasClass('selected'))
            $(this).css(styles.reset);
        });
        $elements.bind('Alchemy.SelectElement', self.selectElement);
        $elements.bind('click', self.clickElement);
        self.$previewElements = $elements;
      },

      selectElement:function (e) {
        var $this = $(this);
        var self = Alchemy.ElementSelector;
        var $elements = self.$previewElements;
        var styles = self.styles;
        var offset = self.scrollOffset;
        e.preventDefault();
        $elements.removeClass('selected').css(styles.reset);
        $this.addClass('selected').css(styles.selected);
        $('html, body').animate({
          scrollTop:$this.offset().top - offset,
          scrollLeft:$this.offset().left - offset
        }, 400);
      },

      clickElement:function (e) {
        var $this = $(this);
        var parent$ = window.parent.jQuery;
        var target_id = $this.attr('data-alchemy-element');
        var $element_editor = parent$('#element_area .element_editor').closest('[id="element_' + target_id + '"]');
        var $elementsWindow = parent$('#alchemyElementWindow');
        e.preventDefault();
        $element_editor.trigger('Alchemy.SelectElementEditor', target_id);
        if ($elementsWindow.dialog("isOpen")) {
          $elementsWindow.dialog('moveToTop');
        } else {
          $elementsWindow.dialog('open');
        }
        $this.trigger('Alchemy.SelectElement');
      }
    }
  });

  Alchemy.ElementSelector.init();

};

if (typeof(jQuery) === 'undefined') {
  Alchemy.loadjQuery(Alchemy.initAlchemyPreviewMode);
} else {
  Alchemy.initAlchemyPreviewMode();
}
