import { vi } from "vitest"

async function importRoutes() {
  vi.resetModules()
  return (await import("alchemy_admin/routes")).routes
}

describe("routes", () => {
  describe("with a routes script tag", () => {
    let routes

    beforeEach(async () => {
      document.body.innerHTML = `
        <script type="application/json" id="alchemy_routes">
          {
            "collection": {"order_admin_elements_path": "/admin/elements/order"},
            "member": {
              "admin_picture_path": "/admin/pictures/1",
              "fold_admin_page_path": "/admin/pages/1/fold?x=1",
              "node": {"move_api_path": "/api/nodes/1/move"}
            }
          }
        </script>
      `
      routes = await importRoutes()
    })

    it("keeps collection routes as strings", () => {
      expect(routes.order_admin_elements_path).toEqual("/admin/elements/order")
    })

    it("turns member routes into functions", () => {
      expect(routes.admin_picture_path(123)).toEqual("/admin/pictures/123")
    })

    it("builds nested member routes", () => {
      expect(routes.node.move_api_path(123)).toEqual("/api/nodes/123/move")
    })

    it("replaces the id only once", () => {
      expect(routes.fold_admin_page_path(12)).toEqual(
        "/admin/pages/12/fold?x=1"
      )
    })
  })

  describe("without a routes script tag", () => {
    it("is empty", async () => {
      document.body.innerHTML = ""
      expect(await importRoutes()).toEqual({})
    })
  })
})
