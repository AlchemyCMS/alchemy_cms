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
      if (payload.parent_id) {
        let parent = this.getters.elementById(payload.parent_id)
        parent.nested_elements.push(payload.element)
      } else {
        state.elements.push(payload.element)
      }
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
    }
  }
}
