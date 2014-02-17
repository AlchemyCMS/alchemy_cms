if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {

  var PageSorter = {};
  $.extend(Alchemy, PageSorter);

  Alchemy.PageSorter = {

    init: function() {
      var $sortables = $('ul#sitemap').find('ul.level_1_children');
      $sortables.nestedSortable({
        disableNesting: 'no-nest',
        forcePlaceholderSize: true,
        handle: '.handle',
        items: 'li',
        listType: 'ul',
        opacity: 0.5,
        placeholder: 'placeholder',
        tabSize: 16,
        tolerance: 'pointer',
        toleranceElement: '> div'
      });
      $('#save_page_order').click(function(e) {
        var params = {
          set: JSON.stringify($sortables.nestedSortable('toHierarchy'))
        };
        $.post(Alchemy.routes.order_admin_pages_path, params);
        return false;
      });
      $('#sort_panel .button').click(Alchemy.pleaseWaitOverlay);
      Alchemy.PageSorter.disableButton();
    },

    disableButton: function() {
      var $buttonLink = $('#page_sorting_button a');
      $buttonLink.removeAttr('onclick');
      $('#page_sorting_button').addClass('active');
      $buttonLink.css({
        cursor: 'default'
      });
    }

  }

})(jQuery);
