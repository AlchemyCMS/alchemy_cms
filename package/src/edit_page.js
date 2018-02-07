import Vue from "vue/dist/vue.esm"
import Vuex from "vuex"
import translate from "./i18n"
import TurbolinksAdapter from "vue-turbolinks"
import AlchemyDialogButton from "./components/dialog_button"
import AlchemyElementsWindow from "./components/elements_window"
import AlchemyPreviewWindow from "./components/preview_window"
import storeConfig from "./vuex_store"

Vue.use(Vuex)
Vue.use(TurbolinksAdapter)
Vue.filter("translate", function (value, replacement) {
  if (!value) return ""
  return translate(value, replacement)
})

window.addEventListener("turbolinks:load", () => {
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
      store,
      beforeDestroy() {
        new Alchemy.Spinner().spin(this.$el.parentNode)
      }
    })
    Alchemy.vuexStore = store
  }
})
