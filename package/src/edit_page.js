import Vue from "vue/dist/vue.esm"
import Vuex from "vuex"
import translate from "./i18n"
import AlchemyDialogButton from "./components/dialog_button"
import AlchemyElementsWindow from "./components/elements_window"
import AlchemyPreviewWindow from "./components/preview_window"
import storeConfig from "./vuex_store"

Vue.use(Vuex)
Vue.filter("translate", function (value, replacement) {
  if (!value) return ""
  return translate(value, replacement)
})

window.addEventListener("DOMContentLoaded", () => {
  const editPage = document.getElementById("edit_page")
  const store = new Vuex.Store(storeConfig)

  if (editPage) {
    Alchemy.eventBus = new Vue()
    Alchemy.vueInstance = new Vue({
      el: editPage,
      components: {
        AlchemyDialogButton,
        AlchemyElementsWindow,
        AlchemyPreviewWindow
      },
      store
    })
    Alchemy.vuexStore = store
  }
})
