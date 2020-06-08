import translate from "./src/i18n"
import NodeTree from "./src/node_tree"
import PageTree from "./src/page_tree"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  // Global utility method for translating a given string
  t: translate,
  NodeTree,
  PageTree
})
