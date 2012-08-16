if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {

  $.extend(Alchemy, {

    ButtonObserver: function(selector) {
      $(selector).not('.no-spinner').click(function(event) {
        Alchemy.disableButton(this);
      });
    },

    disableButton: function(button) {
      var $button = $(button),
        $clone = $button.clone(),
        width = Alchemy.getButtonWidth($button),
        height = Alchemy.getButtonHeight($button),
        spinner = '<img src="/assets/alchemy/ajax_loader.gif" style="width: 16px; height: 16px">';
      $button.hide().addClass('disabled');
      $button.parent().append($clone);
      $clone.attr({
        disabled: true,
        href: 'javascript:void(0)'
      }).addClass('cloned-button').css({
        width: width,
        'line-height': height + 'px'
      }).html(spinner).show();
      return true;
    },

    enableButton: function(button) {
      var $button = $(button).not('.no-spinner');
      $button.show().removeClass('disabled');
      $button.parent().find('.cloned-button').remove();
      return true;
    },

    getButtonWidth: function($button) {
      return $button.outerWidth() - (parseInt($button.css('border-left-width'), 10) + parseInt($button.css('border-right-width'), 10));
    },

    getButtonHeight: function($button) {
      return $button.outerHeight() - (parseInt($button.css('border-top-width'), 10) + parseInt($button.css('border-bottom-width'), 10));
    }

  });

})(jQuery);
