export default {
  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_html">
      <label :for="content.form_field_id">{{ content.label }}</label>
      <textarea v-model="ingredient" :name="content.form_field_name" :id="content.form_field_id">{{content.ingredient}}</textarea>
    </div>
  `,

  data() {
    return {
      ingredient: this.content.ingredient
    }
  }
}
