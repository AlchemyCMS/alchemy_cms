export default {
  props: {
    current: { required: true },
    name: { type: String, required: true },
    id: String,
    type: String
  },

  template: `
    <input type="text"
      v-model="date"
      :name="name"
      :id="id"
      :data-datepicker-type="picker_type">
  `,

  data() {
    const date = this.current ? new Date(this.current) : new Date()
    return {
      picker_type: this.type || "date",
      date: date.toLocaleDateString(Alchemy.locale)
    }
  },

  mounted() {
    Alchemy.Datepicker(this.$el.parentNode)
  }
}
