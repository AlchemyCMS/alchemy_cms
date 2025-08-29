// Creates a fixed element tab.
export function createTab(element_id, label) {
  const fixed_elements = document.getElementById("fixed-elements")
  const panel_name = `fixed-element-${element_id}`

  const tab = `<wa-tab slot="nav" panel="${panel_name}">${label}</wa-tab>`
  const panel = `<wa-tab-panel name="${panel_name}" style="--padding: 0" />`

  fixed_elements.innerHTML += tab + panel

  window.requestAnimationFrame(function () {
    fixed_elements.show(panel_name)
  })
}

export function removeTab(element_id) {
  const fixed_elements = document.getElementById("fixed-elements")
  const panel_name = `fixed-element-${element_id}`

  fixed_elements.querySelector(`wa-tab[panel="${panel_name}"]`).remove()
  fixed_elements.querySelector(`wa-tab-panel[name="${panel_name}"]`).remove()

  fixed_elements.show("main-content-elements")
}
