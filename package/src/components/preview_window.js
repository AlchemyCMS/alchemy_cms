Alchemy.PreviewWindow = {
  postMessage(data) {
    const iFrame = window.alchemy_preview_window
    const frameWindow = iFrame.contentWindow
    frameWindow.postMessage(data, "*")
  },
  reload(element_id) {
    Alchemy.eventBus.$emit("refresh-preview", `${element_id}`)
  },
  resize(size) {
    Alchemy.eventBus.$emit("resize-preview", size)
  }
}

export default {
  props: {
    previewUrl: {
      type: Array,
      required: true
    }
  },

  template: '<iframe :src="url" id="alchemy_preview_window" />',

  data() {
    return {
      url: this._getCurrentPreviewUrl() || this.previewUrl[1],
      minWidth: 240
    }
  },

  created() {
    Alchemy.eventBus.$on("refresh-preview", (element_id) => {
      this.refresh(() => {
        Alchemy.ElementEditors.focusElementPreview(element_id)
      })
    })
    Alchemy.eventBus.$on("resize-preview", this.resize)
  },

  mounted() {
    this.reloadButton = document.getElementById("reload_preview_button")
    this._bindReloadButton()
    this.selectBox = document.getElementById("preview_url")
    if (this.selectBox) {
      this.selectBox.value = this.url
      this._bindSelect()
    }
    this.$el.onload = this._onLoad
    this._showSpinner()
  },

  methods: {
    resize(width) {
      if (width < this.minWidth) width = this.minWidth
      this.$el.style.width = width
    },

    refresh(callback) {
      const onLoad = () => {
        this._onLoad()
        if (callback) callback.call()
      }
      console.log("refresh")
      this.$el.removeEventListener("load", onLoad)
      this.$el.addEventListener("load", onLoad)
      this._showSpinner()
      this.$el.src = this.url
      return true
    },

    // private

    _showSpinner() {
      this.spinner = new Alchemy.Spinner("small")
      this.reloadButton.querySelector(".icon").style.display = "none"
      this.spinner.spin(this.reloadButton)
    },

    _hideSpinner() {
      this.spinner.stop()
      this.reloadButton.querySelector(".icon").style.display = "inline-block"
    },

    _onLoad() {
      this._hideSpinner()
    },

    _bindReloadButton() {
      key("alt+r", () => this.refresh())
      this.reloadButton.addEventListener("click", (e) => {
        e.preventDefault()
        this.refresh()
      })
    },

    _getCurrentPreviewUrl() {
      if (this.selectBox) {
        const option = Array.from(this.selectBox.options).find((option) => {
          return option.text == window.localStorage.getItem("alchemyPreview")
        })
        return option && option.value
      }
      return null
    },

    _bindSelect() {
      this.selectBox.addEventListener("change", (e) => {
        this.url = e.target.value
        option = e.target.querySelector(`option[value='${this.url}']`)
        window.localStorage.setItem("alchemyPreview", option.text)
        this.refresh()
      })
    }
  }
}
