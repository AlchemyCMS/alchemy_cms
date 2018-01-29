export default {
  props: {
    essence: { type: Object, required: true },
    contentId: { type: Number, required: true },
    title: String,
    linkClass: String
  },

  template: `
    <span class="add-essence-link">
      <input type="hidden" :value="essence.link"
        :name="link_form_field_name"
        :id="link_form_field_id">
      <input type="hidden" :value="essence.link_title"
        :name="link_title_form_field_name"
        :id="link_title_form_field_id">
      <input type="hidden" :value="essence.link_class_name"
        :name="link_class_name_form_field_name"
        :id="link_class_name_form_field_id">
      <input type="hidden" :value="essence.link_target"
        :name="link_target_form_field_name"
        :id="link_target_form_field_id">
      <a @click.prevent.stop="openLinkDialog" :title="linkTitle" :class="cssClasses" :data-content-id="contentId">
        <i class="icon fas fa-link fa-fw"></i>
      </a>
    </span>
  `,

  data() {
    const namePrefix = `contents[${this.contentId}]`
    const idPrefix = `contents_${this.contentId}`

    return {
      link_form_field_name: `${namePrefix}[link]`,
      link_title_form_field_name: `${namePrefix}[link_title]`,
      link_class_name_form_field_name: `${namePrefix}[link_class_name]`,
      link_target_form_field_name: `${namePrefix}[link_target]`,
      link_form_field_id: `${idPrefix}_link`,
      link_title_form_field_id: `${idPrefix}_link_title`,
      link_class_name_form_field_id: `${idPrefix}_link_class_name`,
      link_target_form_field_id: `${idPrefix}_link_target`,
      linkTitle: this.title || Alchemy.t("place_link")
    }
  },

  mounted() {
    // The Alchemy.LinkDialog sets the value of the hidden field.
    // As Vue does not watch DOM changes, we need to watch the changes of each field to sync the data.
    // This can probably be refactored if we switch to a data store.
    $(`#${this.link_form_field_id}`).on("change", (e) => {
      this.essence.link = e.currentTarget.value
    })
    $(`#${this.link_title_form_field_id}`).on("change", (e) => {
      this.essence.link_title = e.currentTarget.value
    })
    $(`#${this.link_class_name_form_field_id}`).on("change", (e) => {
      this.essence.link_class_name = e.currentTarget.value
    })
    $(`#${this.link_target_form_field_id}`).on("change", (e) => {
      this.essence.link_target = e.currentTarget.value
    })
  },

  computed: {
    cssClasses() {
      let classes = ["link-essence"]
      if (this.linkClass) classes.push(this.linkClass)
      if (this.essence.link) classes.push("linked")
      return classes.join(" ")
    }
  },

  methods: {
    openLinkDialog(e) {
      new Alchemy.LinkDialog(e.currentTarget).open()
    }
  }
}
