import Vue from "vue/dist/vue.esm"
import translate from "./i18n"
import AlchemyDialogButton from "./components/dialog_button"
import AlchemyElementsWindow from "./components/elements_window"
import AlchemyPreviewWindow from "./components/preview_window"

Vue.filter("translate", function (value, replacement) {
  if (!value) return ""
  return translate(value, replacement)
})

window.addEventListener("DOMContentLoaded", () => {
  const editPage = document.getElementById("edit_page")

  if (editPage) {
    Alchemy.eventBus = new Vue()
    Alchemy.vueInstance = new Vue({
      el: editPage,
      components: {
        AlchemyDialogButton,
        AlchemyElementsWindow,
        AlchemyPreviewWindow
      }
    })
  }
})
