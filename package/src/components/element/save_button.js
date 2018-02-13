export default {
  props: {
    element: { type: Object, required: true }
  },

  template: `
    <button :form="elementForm" @click.prevent="save" type="submit" class="button" data-alchemy-button>
      {{ 'save' | translate }}
    </button>
  `,

  data() {
    return {
      elementForm: `element_${this.element.id}_form`
    }
  },

  methods: {
    save(e) {
      const params = $(e.currentTarget.form).serialize()
      Alchemy.Buttons.disable(this.$el)
      $.ajax(Alchemy.routes.admin_element_path(this.element.id), {
        type: "POST",
        method: "PUT",
        data: params
      })
        .done((responseData) => {
          Alchemy.growl(Alchemy.t("element_saved"))
          Alchemy.reloadPreview(this.element.id)
          Alchemy.setElementClean(`#element_${this.element.id}`)
          this.$store.commit("updateElement", responseData.element)
        })
        .fail((response) => {
          if (response.status === 422) {
            const error = response.responseJSON
            Alchemy.growl(error.message, "warn")
            this.$store.commit("updateElement", error.element)
          } else {
            throw response.statusText
          }
        })
        .always(() => {
          Alchemy.Buttons.enable(this.$el.parentElement)
        })
    }
  }
}
