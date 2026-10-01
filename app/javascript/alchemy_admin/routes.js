import { readJSONScript } from "alchemy_admin/utils/json_script"

// Member routes are rendered with 1 as the record id and become functions
// that put the given id in its place.
function buildRoutes({ collection = {}, member = {} } = {}) {
  const routes = { ...collection }

  Object.entries(member).forEach(([name, path]) => {
    routes[name] =
      typeof path === "string"
        ? (id) => path.replace(/1/, id)
        : buildRoutes({ member: path })
  })

  return routes
}

export const routes = buildRoutes(readJSONScript("alchemy_routes"))
