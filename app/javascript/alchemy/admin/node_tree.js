import Sortable from "sortablejs"
import ajax from "./utils/ajax"
import { on } from "./utils/events"

function displayNodeFolders() {
  document.querySelectorAll("li.menu-item").forEach((el) => {
    const leftIconArea = el.querySelector(".nodes_tree-left_images")
    const list = el.querySelector(".children")
    const node = { folded: el.dataset.folded === "true", id: el.dataset.id }

    if (list.children.length > 0 || node.folded) {
      leftIconArea.innerHTML = HandlebarsTemplates.node_folder({ node: node })
    } else {
      leftIconArea.innerHTML = "&nbsp;"
    }
  })
}

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
      displayNodeFolders()
    })
    .catch((error) => {
      Alchemy.growl(error.message || error, "error")
    })
}

function handleNodeFolders() {
  on("click", ".nodes_tree", ".node_folder", function () {
    const nodeId = this.dataset.nodeId
    const menu_item = this.closest("li.menu-item")
    const url = Alchemy.routes.toggle_folded_api_node_path(nodeId)
    const list = menu_item.querySelector(".children")

    ajax("PATCH", url)
      .then(() => {
        list.classList.toggle("folded")
        menu_item.dataset.folded =
          menu_item.dataset.folded == "true" ? "false" : "true"
        displayNodeFolders()
      })
      .catch((error) => {
        Alchemy.growl(error.message || error)
      })
  })
}

export default function NodeTree() {
  handleNodeFolders()
  displayNodeFolders()

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
