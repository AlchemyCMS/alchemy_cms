import translate from "alchemy/admin/i18n"
import NodeTree from "alchemy/admin/node_tree"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  // Global utility method for translating a given string
  t: translate,
  NodeTree
})
