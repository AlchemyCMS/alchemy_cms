import Sortable from "sortablejs"
import { patch } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"
import { translate } from "alchemy_admin/i18n"

/**
 * Custom element for the nodes tree container
 * Handles drag and drop sorting of its menu nodes
 */
export class AlchemyNodeTree extends HTMLElement {
  connectedCallback() {
    this.querySelectorAll("ul.children").forEach((list) => {
      new Sortable(list, {
        group: "nodes",
        animation: 150,
        fallbackOnBody: true,
        swapThreshold: 0.65,
        handle: ".node_name",
        invertSwap: true,
        draggable: "alchemy-menu-node",
        onEnd: (event) => this.handleSort(event)
      })
    })
  }

  async handleSort(event) {
    if (event.from === event.to && event.oldIndex === event.newIndex) {
      return
    }

    const url = Alchemy.routes.node.move_api_path(event.item.nodeId)
    const data = {
      target_parent_id: event.to.dataset.recordId,
      new_position: event.newIndex
    }

    try {
      await patch(url, data)
      this.updateFolders(event.from, event.to)
      growl(translate("Successfully moved menu item"))
    } catch (error) {
      growl(error.message || error, "error")
    }
  }

  updateFolders(from, to) {
    from.closest("alchemy-menu-node")?.updateFolder()

    if (from !== to) {
      to.closest("alchemy-menu-node")?.updateFolder()
    }
  }
}

customElements.define("alchemy-node-tree", AlchemyNodeTree)
