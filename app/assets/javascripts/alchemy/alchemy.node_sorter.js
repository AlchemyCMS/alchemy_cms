Alchemy.NodeSorter = function() {
  var $sortables = $('ul.nodes_tree');

  $sortables.nestedSortable({
    forcePlaceholderSize: true,
    handle: '.handle',
    items: 'li',
    listType: 'ul',
    opacity: 0.5,
    placeholder: 'placeholder',
    tabSize: 16,
    tolerance: 'pointer',
    toleranceElement: '> div',
    protectRoot: true
  });

  $('#save_node_order').click(function(e) {
    e.preventDefault();
    Alchemy.Buttons.disable(this);
    $.post(Alchemy.routes.order_admin_nodes_path, {
      set: JSON.stringify($sortables.nestedSortable('toHierarchy'))
    });
  });
};
