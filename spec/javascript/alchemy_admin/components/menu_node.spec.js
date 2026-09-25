import { describe, it, expect, vi, beforeEach, afterEach } from "vitest"
import { patch } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"
import "alchemy_admin/components/menu_node"
import "alchemy_admin/components/node_folder"

vi.mock("alchemy_admin/utils/ajax", () => ({
  patch: vi.fn(() => Promise.resolve())
}))

vi.mock("alchemy_admin/growler", () => ({
  growl: vi.fn()
}))

// Add missing Alchemy globals (Alchemy is already set up in setup.js)
Alchemy.routes.node = {
  toggle_folded_api_path: (id) => `/api/nodes/${id}/toggle_folded`
}

describe("AlchemyMenuNode", () => {
  let container
  let element

  const menuNode = (id, { folded = false, children = "" } = {}) => `
    <alchemy-menu-node node-id="${id}" ${folded ? "folded" : ""}>
      <li class="menu-item">
        <div class="sitemap_node">
          <span class="nodes_tree-left_images">
            <alchemy-node-folder ${folded ? "folded" : ""}></alchemy-node-folder>
          </span>
          <div class="node_name">Node ${id}</div>
        </div>
        <ul class="children ${folded ? "folded" : ""}" data-record-id="${id}">
          ${children}
        </ul>
      </li>
    </alchemy-menu-node>
  `

  beforeEach(() => {
    container = document.createElement("div")
    container.innerHTML = menuNode(123)
    document.body.appendChild(container)
    element = container.querySelector("alchemy-menu-node")
  })

  afterEach(() => {
    document.body.removeChild(container)
    vi.clearAllMocks()
  })

  describe("initialization", () => {
    it("reads the node id from its attribute", () => {
      expect(element.nodeId).toBe("123")
    })

    it("is unfolded without a folded attribute", () => {
      expect(element.folded).toBe(false)
    })

    it("is folded with a folded attribute", () => {
      container.innerHTML = menuNode(456, { folded: true })

      expect(container.querySelector("alchemy-menu-node").folded).toBe(true)
    })
  })

  describe("clicking the folder", () => {
    const clickFolder = async (node = element) => {
      node.querySelector("button.node_folder").click()
      await vi.waitFor(() => expect(patch).toHaveBeenCalled())
    }

    it("patches the toggle folded endpoint", async () => {
      await clickFolder()

      expect(patch).toHaveBeenCalledWith("/api/nodes/123/toggle_folded")
    })

    it("folds the node", async () => {
      await clickFolder()

      expect(element.folded).toBe(true)
      expect(element.hasAttribute("folded")).toBe(true)
    })

    it("hides the children", async () => {
      await clickFolder()

      const children = element.querySelector(".children")
      await vi.waitFor(() =>
        expect(children.classList.contains("folded")).toBe(true)
      )
    })

    it("folds the folder arrow", async () => {
      await clickFolder()

      const folder = element.querySelector("alchemy-node-folder")
      await vi.waitFor(() => expect(folder.hasAttribute("folded")).toBe(true))
    })

    it("unfolds an already folded node", async () => {
      container.innerHTML = menuNode(456, { folded: true })
      const foldedNode = container.querySelector("alchemy-menu-node")

      await clickFolder(foldedNode)

      await vi.waitFor(() => expect(foldedNode.folded).toBe(false))
      expect(
        foldedNode.querySelector(".children").classList.contains("folded")
      ).toBe(false)
    })

    it("does not react to a click on a nested node's folder", async () => {
      container.innerHTML = menuNode(123, { children: menuNode(456) })
      const parent = container.querySelector('alchemy-menu-node[node-id="123"]')
      const child = container.querySelector('alchemy-menu-node[node-id="456"]')

      await clickFolder(child)

      expect(patch).toHaveBeenCalledTimes(1)
      expect(patch).toHaveBeenCalledWith("/api/nodes/456/toggle_folded")
      expect(parent.folded).toBe(false)
    })

    it("growls the error and keeps its state when the request fails", async () => {
      patch.mockRejectedValueOnce(new Error("Network error"))

      await clickFolder()

      await vi.waitFor(() =>
        expect(growl).toHaveBeenCalledWith("Network error", "error")
      )
      expect(element.folded).toBe(false)
      expect(
        element.querySelector(".children").classList.contains("folded")
      ).toBe(false)
    })
  })

  describe("hasChildren", () => {
    it("is true when the node has child menu nodes", () => {
      container.innerHTML = menuNode(123, { children: menuNode(456) })

      expect(
        container.querySelector('alchemy-menu-node[node-id="123"]').hasChildren
      ).toBe(true)
    })

    it("is false when the node has no child menu nodes", () => {
      expect(element.hasChildren).toBe(false)
    })
  })

  describe("updateFolder", () => {
    it("shows the folder when the node has children", () => {
      container.innerHTML = menuNode(123, { children: menuNode(456) })
      const parent = container.querySelector('alchemy-menu-node[node-id="123"]')

      parent.updateFolder()

      expect(parent.folder.hidden).toBe(false)
    })

    it("hides the folder when the node has no children", () => {
      element.updateFolder()

      expect(element.folder.hidden).toBe(true)
    })

    it("shows the folder of a folded node without children", () => {
      container.innerHTML = menuNode(456, { folded: true })
      const foldedNode = container.querySelector("alchemy-menu-node")

      foldedNode.updateFolder()

      expect(foldedNode.folder.hidden).toBe(false)
    })
  })
})
