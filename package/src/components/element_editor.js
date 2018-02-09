import AlchemyElementHeader from "./element/header"
import AlchemyElementToolbar from "./element/toolbar"
import AlchemyElementFooter from "./element/footer"

export default {
  props: {
    element: { type: Object, required: true }
  },

  template: `
    <div :id="elementId" :data-element-id="element.id" :data-element-name="element.name" :class="cssClasses">
      <alchemy-element-header :element="element"></alchemy-element-header>
      <template v-if="!element.folded">
        <alchemy-element-toolbar :element="element"></alchemy-element-toolbar>
        <div class="element-content"></div>
        <alchemy-element-footer :element="element"></alchemy-element-footer>
      </template>
    </div>
  `,

  components: {
    AlchemyElementHeader,
    AlchemyElementToolbar,
    AlchemyElementFooter
  },

  data() {
    const element = this.element
    return {
      elementId: `element_${element.id}`
    }
  },

  computed: {
    cssClasses() {
      let classes = ["element-editor"]

      classes.push(
        this.element.contents.length ? "with-contents" : "without-contents"
      )
      classes.push(
        this.element.nestable_elements.length ? "nestable" : "not-nestable"
      )
      classes.push(this.element.taggable ? "taggable" : "not-taggable")
      classes.push(this.element.folded ? "folded" : "expanded")
      if (this.element.compact) classes.push("compact")
      if (this.element.deprecated) classes.push("deprecated")
      classes.push(this.element.fixed ? "fixed" : "not-fixed")
      classes.push(this.element.public ? "visible" : "hidden")

      return classes.join(" ")
    }
  }
}
