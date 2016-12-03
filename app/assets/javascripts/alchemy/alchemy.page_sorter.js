Alchemy.PageSorter = function() {
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
    e.preventDefault();
    Alchemy.Buttons.disable(this);
    $.post(Alchemy.routes.order_admin_pages_path, {
      set: JSON.stringify($sortables.nestedSortable('toHierarchy'))
    });
  });
};
