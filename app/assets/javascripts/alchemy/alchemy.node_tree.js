Alchemy.NodeTree = {
  onFinishDragging: function (evt) {
    var url = '/api/nodes/' + evt.item.dataset.id + '/move.json'
    var xhr = new XMLHttpRequest()
    var token = document.querySelector('meta[name="csrf-token"]').attributes.content.textContent
    var data = {
      target_parent_id: evt.to.dataset.nodeId,
      new_position: evt.newIndex
    };
    var json = JSON.stringify(data)
    xhr.open("PATCH", url);
    xhr.setRequestHeader('Content-type', 'application/json; charset=utf-8');
    xhr.setRequestHeader('X-CSRF-Token', token)
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
    var generate_link = function (node_id, folded) {
      var icon = folded === "true" ? 'plus' : 'minus';
      return '<a class="node_folder" data-node-id="' + node_id + '"><i class="far fa-' + icon + '-square fa-fw"></i></a>'
    }

    document.querySelectorAll('li.menu-item').forEach(function (el) {
      var leftIconArea = el.querySelector('.nodes_tree-left_images')
      var list = el.querySelector('ul')

      if (list.children.length > 0 || el.dataset.folded === 'true' ) {
        leftIconArea.innerHTML = generate_link(el.dataset.id, el.dataset.folded)
      } else {
        leftIconArea.innerHTML = '&nbsp;'
      }
    });

    this.handleNodeFolders();
  },

  handleNodeFolders: function() {
    var folders = document.querySelectorAll('.nodes_tree .node_folder');

    folders.forEach(function(folder){
      folder.addEventListener('click', function(evt) {
        var nodeId = this.dataset.nodeId
        var menu_item = this.closest('li.menu-item')
        var url = '/admin/nodes/' + nodeId + '/toggle.html'
        var list = menu_item.querySelector('.children')
        var xhr = new XMLHttpRequest()
        var token = document.querySelector('meta[name="csrf-token"]').attributes.content.textContent

        xhr.open("PATCH", url);
        xhr.setRequestHeader('Content-type', 'application/json; charset=utf-8');
        xhr.setRequestHeader('X-CSRF-Token', token)

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
      })
    });
  },

  init: function() {
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
