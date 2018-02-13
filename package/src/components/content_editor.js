import AlchemyEssencePicture from "./essences/essence_picture"
import AlchemyEssenceText from "./essences/essence_text"
import AlchemyEssenceHtml from "./essences/essence_html"
import AlchemyEssenceDate from "./essences/essence_date"
import AlchemyEssenceBoolean from "./essences/essence_boolean"
import AlchemyEssenceSelect from "./essences/essence_select"
import AlchemyEssenceLink from "./essences/essence_link"
import AlchemyEssenceFile from "./essences/essence_file"
import AlchemyEssenceRichtext from "./essences/essence_richtext"

export default {
  components: {
    AlchemyEssencePicture,
    AlchemyEssenceText,
    AlchemyEssenceHtml,
    AlchemyEssenceDate,
    AlchemyEssenceBoolean,
    AlchemyEssenceSelect,
    AlchemyEssenceLink,
    AlchemyEssenceFile,
    AlchemyEssenceRichtext
  },

  props: {
    content: { type: Object, required: true }
  },

  template: `<div
    :is="content.component_name"
    :content="content"
    :data-content-id="content.id"
    :class="cssClasses">
  </div>`,

  computed: {
    cssClasses() {
      let classes = ["content_editor"]
      if (this.content.deprecated) classes.push("deprecated")
      if (this.content.validation_errors.length)
        classes.push("validation_failed")
      return classes
    }
  }
}
