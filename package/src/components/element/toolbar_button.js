export default {
  props: {
    url: { type: String, required: true },
    icon: { type: String, required: true },
    label: { type: String, required: true },
    alt_label: String,
    method: String
  },

  template: `<div class="button_with_label">
    <a class="icon_button" @click.prevent="onClick">
      <i :class="cssClasses"></i>
    </a>
    <label>{{ label | translate }}</label>
  </div>`,

  computed: {
    cssClasses() {
      return `icon fas fa-fw fa-${this.icon}`
    }
  },

  methods: {
    onClick() {
      $.ajax(this.url, {
        method: this.method || "POST"
      }).done((responseData) => {
        this.$emit("requestDone", responseData)
      })
    }
  }
}
