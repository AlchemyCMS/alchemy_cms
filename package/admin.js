import translate from "./src/i18n"
import NodeTree from "./src/node_tree"
import fileEditors from "./src/file_editors"
import pictureEditors from "./src/picture_editors"
import ImageLoader from "./src/image_loader"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  // Global utility method for translating a given string
  t: translate,
  NodeTree,
  fileEditors,
  pictureEditors,
  ImageLoader: ImageLoader.init
})
