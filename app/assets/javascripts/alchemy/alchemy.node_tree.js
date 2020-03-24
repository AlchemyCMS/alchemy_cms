Alchemy.NodeTree = {
  onFinishDragging: function (evt) {
    var url = '/api/nodes/' + evt.item.dataset.id + '/move.json'
    var xhr = Alchemy.xhr('PATCH', url)
    var data = {
      target_parent_id: evt.to.dataset.nodeId,
      new_position: evt.newIndex
    };
    var json = JSON.stringify(data)

    evt.to.parentElement.dataset.folded = 'false'
    evt.to.classList.remove('folded')
    xhr.onload = function () {
      response_json = JSON.parse(xhr.responseText)
      if (xhr.readyState == 4 && xhr.status == "200") {
        Alchemy.NodeTree.displayNodeFolders()
      } else {
        Alchemy.growl(response_json.error, 'error');
      }
    }
    xhr.send(json)
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
      var url = '/admin/nodes/' + nodeId + '/toggle.html'
      var list = menu_item.querySelector('.children')
      var xhr = Alchemy.xhr('PATCH', url)

      xhr.onload = function () {
        if (xhr.readyState == 4 && xhr.status == "200") {
          list.classList.toggle('folded')
          menu_item.dataset.folded = menu_item.dataset.folded == 'true' ? 'false' : 'true'
          Alchemy.NodeTree.displayNodeFolders();
        } else {
          Alchemy.growl('error folding');
        }
      }
      xhr.send()
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
