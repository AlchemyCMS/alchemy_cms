import Sortable from "sortablejs"
import ajax from "./utils/ajax"
import { updateFolderLinks, handleFolderLinks } from "./folder_links"

const nodeSelector = "li.menu-item"

function onFinishDragging(evt) {
  const url = Alchemy.routes.move_api_node_path(evt.item.dataset.id)
  const data = {
    target_parent_id: evt.to.dataset.nodeId,
    new_position: evt.newIndex
  }

  ajax("PATCH", url, data)
    .then(() => {
      const message = Alchemy.t("Successfully moved menu item")
      Alchemy.growl(message)
      updateFolderLinks(nodeSelector)
    })
    .catch((error) => {
      Alchemy.growl(error.message || error, "error")
    })
}

export default function NodeTree() {
  handleFolderLinks(".nodes_tree", {
    url: Alchemy.routes.toggle_folded_api_node_path,
    parent_selector: nodeSelector
  })
  updateFolderLinks(nodeSelector)

  document.querySelectorAll(".nodes_tree ul.children").forEach((el) => {
    new Sortable(el, {
      group: "nodes",
      animation: 150,
      fallbackOnBody: true,
      swapThreshold: 0.65,
      handle: ".node_name",
      invertSwap: true,
      onEnd: onFinishDragging
    })
  })
}
