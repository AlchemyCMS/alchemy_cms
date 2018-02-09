import Vue from "vue/dist/vue.esm"
import AlchemyPreviewWindow from "./components/preview_window"

window.addEventListener("DOMContentLoaded", () => {
  const editPage = document.getElementById("edit_page")

  if (editPage) {
    Alchemy.eventBus = new Vue()
    Alchemy.vueInstance = new Vue({
      el: editPage,
      components: { AlchemyPreviewWindow }
    })
  }
})
