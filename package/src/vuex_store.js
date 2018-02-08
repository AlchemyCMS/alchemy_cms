export default {
  state: { elements: [] },

  getters: {
    elementById: (state) => (id) => {
      return (function find(elements) {
        let element = elements.find((element) => element.id === id)
        if (element) return element
        for (let element of elements) {
          return find(element.nested_elements)
        }
      })(state.elements)
    }
  },

  mutations: {
    addElement(state, payload) {
      let elements
      if (payload.parent_id) {
        const parent = this.getters.elementById(payload.parent_id)
        elements = parent.nested_elements
      } else {
        elements = state.elements
      }
      if (payload.insert_at_top) {
        elements.unshift(payload.element)
      } else {
        elements.push(payload.element)
      }
    },

    updateElement(_state, payload) {
      let element = this.getters.elementById(payload.id)
      Object.assign(element, payload)
    },

    removeElement(state, payload) {
      if (payload.parent_id) {
        let parent = this.getters.elementById(payload.parent_id)
        parent.nested_elements = parent.nested_elements.filter(function (
          element
        ) {
          return element.id !== payload.element_id
        })
      } else {
        state.elements = state.elements.filter(function (element) {
          return element.id !== payload.element_id
        })
      }
    },

    selectElement(state, element_id) {
      function toggleElements(elements) {
        for (let element of elements) {
          if (element.id === element_id) {
            element.selected = true
          } else {
            element.selected = false
          }
          toggleElements(element.nested_elements)
        }
      }
      toggleElements(state.elements)
    }
  },

  assignFile(_state, payload) {
    let element = this.getters.elementById(payload.element_id)
    let content = element.contents.find(
      (content) => content.id === payload.content_id
    )
    let essence = content.essence.essence_file
    essence.attachment = payload.attachment
    essence.attachment_id = payload.attachment.id
  }
}
