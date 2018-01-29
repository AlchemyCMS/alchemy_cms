export default {
  props: {
    essence: { type: Object, required: true },
    linkClass: String
  },

  template: `
    <a @click.prevent.stop="removeLink" :title="'unlink' | translate" :class="cssClasses" :tabindex="tabindex">
      <i class="fas fa-unlink fa-fw"></i>
    </a>
  `,

  computed: {
    cssClasses() {
      let classes = [
        "unlink-essence",
        this.essence.link ? "linked" : "disabled"
      ]
      if (this.linkClass) classes.push(this.linkClass)
      return classes.join(" ")
    },
    tabindex() {
      if (this.essence.link) {
        return false
      } else {
        return "-1"
      }
    }
  },

  methods: {
    removeLink() {
      if (this.essence.link) {
        Alchemy.setElementDirty($(this.$el).closest(".element-editor"))
      }
      this.essence.link = ""
      this.essence.link_title = ""
      this.essence.link_class_name = ""
      this.essence.link_target = ""
    }
  }
}
