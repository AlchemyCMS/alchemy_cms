import AlchemyContentLabel from "./content_label"

export default {
  components: {
    AlchemyContentLabel
  },

  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_richtext">
      <alchemy-content-label :content="content"></alchemy-content-label>
      <div class="tinymce_container">
        <textarea
          v-model="ingredient"
          class="has_tinymce"
          :id="domId"
          :name="content.form_field_name"></textarea>
      </div>
    </div>
  `,

  data() {
    return {
      ingredient: this.content.ingredient,
      domId: `tinymce_${this.content.id}`
    }
  },

  mounted() {
    const config = this.content.settings.tinymce
    Alchemy.Tinymce.initEditor(this.content.id, config)
    let editor = tinymce.get(`tinymce_${this.content.id}`)
    editor.on("change", (e) => {
      this.ingredient = e.target.getContent()
    })
  },

  beforeDestroy() {
    Alchemy.Tinymce.remove([this.content.id])
  }
}
