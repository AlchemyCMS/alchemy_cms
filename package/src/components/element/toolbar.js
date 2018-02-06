import AlchemyElementToolbarButton from "./toolbar_button"

export default {
  props: {
    element: { type: Object, required: true }
  },

  template: `<div class="element-toolbar">
    <span class="element_tools">
      <alchemy-element-toolbar-button
        :url="copyElementUrl" icon="clone" label="copy_element"
        @requestDone="afterCopyElement">
      </alchemy-element-toolbar-button>
      <alchemy-element-toolbar-button
        :url="cutElementUrl" icon="cut" label="cut_element"
        @requestDone="afterCutElement">
      </alchemy-element-toolbar-button>
      <!--alchemy-confirm-dialog-button
        :url="deleteElementUrl"
        icon="trash-alt"
        label="Delete element"
        @requestDone="afterDeleteElement">
      </alchemy-confirm-dialog-button-->
      <alchemy-element-toolbar-button
        :url="hideElementUrl" method="patch"
        :icon="hideElementIcon"
        :label="hideElementLabel"
        @requestDone="afterHideElement">
      </alchemy-element-toolbar-button>
    </span>
  </div>`,

  components: { AlchemyElementToolbarButton },

  data() {
    const alchemy = Alchemy.routes,
      id = this.element.id
    return {
      copyElementUrl: alchemy.copy_admin_element_path(id),
      cutElementUrl: alchemy.cut_admin_element_path(id),
      deleteElementUrl: alchemy.destroy_admin_element_path(id),
      hideElementUrl: alchemy.publish_admin_element_path(id)
    }
  },

  computed: {
    hideElementLabel() {
      return this.element.public ? "hide_element" : "show_element"
    },
    hideElementIcon() {
      return this.element.public ? "eye-slash" : "eye"
    }
  },

  methods: {
    afterCopyElement() {
      let notice = Alchemy.t(
        "item copied to clipboard",
        this.element.display_name
      )
      Alchemy.growl(notice)
      $("#clipboard_button .icon")
        .removeClass("fa-clipboard")
        .addClass("fa-paste")
    },

    afterCutElement() {
      let notice = Alchemy.t(
        "item moved to clipboard",
        this.element.display_name
      )
      Alchemy.growl(notice)
      this._removeElement()
      $("#clipboard_button .icon")
        .removeClass("fa-clipboard")
        .addClass("fa-paste")
    },

    afterDeleteElement() {
      $(`#element_${this.element.id}`).hide(200, function () {
        Alchemy.growl(Alchemy.t("Element trashed"))
        this._removeElement()
        Alchemy.PreviewWindow.reload()
        if (this.element.fixed) {
          Alchemy.FixedElements.removeTab(this.element.id)
        }
      })
    },

    afterHideElement(responseData) {
      this.element.public = responseData.public
      Alchemy.PreviewWindow.reload()
    },

    _removeElement() {
      this.$store.commit("removeElement", {
        parent_id: this.element.parent_element_id,
        element_id: element.id
      })
    }
  }
}
