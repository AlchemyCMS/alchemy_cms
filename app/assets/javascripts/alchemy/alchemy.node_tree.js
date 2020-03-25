Alchemy.NodeTree = {
  onFinishDragging: function (evt) {
    var url = Alchemy.routes.move_api_node_path(evt.item.dataset.id)
    var data = {
      target_parent_id: evt.to.dataset.nodeId,
      new_position: evt.newIndex
    };
    var ajax = Alchemy.ajax('PATCH', url, data)

    ajax.then(function(response) {
      Alchemy.growl('Successfully moved menu item.')
      Alchemy.NodeTree.displayNodeFolders()
    }).catch(function() {
      Alchemy.growl(error.message || error);
    })
  },

  displayNodeFolders: function () {
    document.querySelectorAll('li.menu-item').forEach(function (el) {
      var leftIconArea = el.querySelector('.nodes_tree-left_images')
      var list = el.querySelector('ul')
      var node = { folded: el.dataset.folded === 'true', id: el.dataset.id }

      if (list.children.length > 0 || node.folded ) {
        leftIconArea.innerHTML = HandlebarsTemplates.node_folder({ node: node })
      } else {
        leftIconArea.innerHTML = '&nbsp;'
      }
    });
  },

  handleNodeFolders: function() {
    Alchemy.on('click', '.nodes_tree', '.node_folder', function(evt) {
      var nodeId = this.dataset.nodeId
      var menu_item = this.closest('li.menu-item')
      var url = Alchemy.routes.toggle_folded_api_node_path(nodeId)
      var list = menu_item.querySelector('.children')
      var ajax = Alchemy.ajax('PATCH', url)

      ajax.then(function() {
        list.classList.toggle('folded')
        menu_item.dataset.folded = menu_item.dataset.folded == 'true' ? 'false' : 'true'
        Alchemy.NodeTree.displayNodeFolders();
      }).catch(function(error){
        Alchemy.growl(error.message || error);
      });
    });
  },

  init: function() {
    this.handleNodeFolders()
    this.displayNodeFolders()

    document.querySelectorAll('.nodes_tree ul.children').forEach(function (el) {
      new Sortable(el, {
        group: 'nodes',
        animation: 150,
        fallbackOnBody: true,
        swapThreshold: 0.65,
        handle: '.node_name',
        invertSwap: true,
        onEnd: Alchemy.NodeTree.onFinishDragging
      });
    });
  }
}
