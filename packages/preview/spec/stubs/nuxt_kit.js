export const addedPlugins = []

export function defineNuxtModule(definition) {
  return definition
}

export function addPlugin(plugin) {
  addedPlugins.push(plugin)
}

export function createResolver(base) {
  return { resolve: (path) => new URL(path, base).pathname }
}
