window.Alchemy = Alchemy || {}

Alchemy.FixedElements = {
  WRAPPER: '<sl-tab-group id="fixed-elements" />',
  TABS: '<sl-tab slot="nav" panel="main-content-elements">{{label}}</sl-tab>',

  // Creates a fixed element tab.
  createTab: function (element_id, label) {
    var $fixed_elements = $("#fixed-elements")
    var panel_name = "fixed-element-" + element_id

    var $tab =
      '<sl-tab slot="nav" panel="' + panel_name + '">' + label + "</sl-tab>"
    $fixed_elements.append($tab)

    var $panel = $(
      '<sl-tab-panel name="' + panel_name + '" style="--padding: 0" />'
    )
    $fixed_elements.append($panel)
    window.requestAnimationFrame(function () {
      $fixed_elements.get(0).show(panel_name)
    })
  },

  removeTab: function (element_id) {
    var $fixed_elements = $("#fixed-elements")

    $fixed_elements
      .find('sl-tab[panel="fixed-element-' + element_id + '"]')
      .remove()
    $fixed_elements
      .find('sl-tab-panel[name="fixed-element-' + element_id + '"]')
      .remove()
    $fixed_elements.get(0).show("main-content-elements")
  }
}
