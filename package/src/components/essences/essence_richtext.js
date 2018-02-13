import AlchemyContentError from "./content_error"
import AlchemyContentLabel from "./content_label"

export default {
  components: {
    AlchemyContentError,
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
      <alchemy-content-error :content="content"></alchemy-content-error>
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
