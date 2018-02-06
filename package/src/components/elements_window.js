import AlchemyDialogButton from "./dialog_button"
import AlchemyElementEditor from "./element_editor"

export default {
  props: {
    url: { type: String, required: true },
    pageId: { type: Number, required: true },
    topMenuHeight: String,
    richtextContentIds: Array
  },

  template: `
  <div id="alchemy_elements_window">
    <div id="elements_toolbar">
      <slot />
    </div>
    <div id="element_area">
      <div id="main-content-elements" class="sortable-elements">
        <alchemy-element-editor
          v-for="element in elements"
          :key="element.id"
          :element="element"
        ></alchemy-element-editor>
      </div>
    </div>
  </div>`,

  components: {
    AlchemyDialogButton,
    AlchemyElementEditor
  },

  data() {
    const alchemy = Alchemy.routes
    return {
      newElementUrl: alchemy.new_admin_element_path(this.pageId),
      clipboardUrl: alchemy.admin_clipboard_path("elements")
    }
  },

  created() {
    this.hidden = false
  },

  mounted() {
    this.$body = $("body")
    this.$elements_window = $(this.$el)
    this.$element_toolbar = $("#elements_toolbar")
    this.$element_area = $("#element_area")
    this.$button = $("#element_window_button")
    this.$button.click((e) => {
      e.preventDefault()
      this.toggle()
    })
    // Blur selected elements
    $("body").click((e) => {
      let element = $(e.target).parents(".element-editor")[0]
      // Not passing an element id here actually unselects all elements
      this.$store.commit("selectElement")
      if (!element) {
        Alchemy.PreviewWindow.postMessage(
          { message: "Alchemy.blurElements" },
          window.location.origin
        )
      }
    })
    this.show()
    this.load()
  },

  computed: {
    elements() {
      return this.$store.state.elements
    }
  },

  methods: {
    resize() {
      let height = $(window).height() - this.topMenuHeight
      this.$element_area.css({
        height: height - this.$element_toolbar.outerHeight()
      })
    },

    load() {
      const spinner = new Alchemy.Spinner("medium")
      spinner.spin(this.$element_area[0])
      $.getJSON(this.url, (responseData) => {
        // Unselect all elements so that we can use this state in the Vuex store
        function unselectElements(elements) {
          for (let element of elements) {
            element.selected = false
            unselectElements(element.nested_elements || [])
          }
        }
        unselectElements(responseData.elements)
        this.$store.replaceState({ elements: responseData.elements })
        // $("#fixed-elements").tabs().tabs("paging", {
        //   follow: true,
        //   followOnSelect: true,
        //   prevButton: '<i class="fas fa-angle-double-left"></i>',
        //   nextButton: '<i class="fas fa-angle-double-right"></i>'
        // })
        Alchemy.SortableElements(this.pageId)
      })
        .fail((xhr, status, error) => {
          Alchemy.AjaxErrorHandler(
            this.$element_area,
            xhr.status,
            status,
            error
          )
        })
        .always(() => spinner.stop())
    },

    toggle() {
      if (this.hidden) {
        this.show()
      } else {
        this.hide()
      }
      this.toggleButton()
    },

    hide() {
      this.$body.removeClass("elements-window-visible")
      this.hidden = true
    },

    show() {
      this.$body.addClass("elements-window-visible")
      this.hidden = false
    },

    toggleButton() {
      if (this.hidden) {
        this.$button.find("label").text("Show elements")
      } else {
        this.$button.find("label").text("Hide elements")
      }
    }
  }
}
