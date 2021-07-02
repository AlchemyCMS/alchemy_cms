window.Alchemy = Alchemy || {};

Alchemy.FixedElements = {
  WRAPPER: '<div id="fixed-elements"></div>',
  TABS: '<ul><li><a href="#main-content-elements">{{label}}</a></li></ul>',

  // Builds fixed elements tabs
  buildTabs: function(label) {
    var $wrapper = $(this.WRAPPER),
        $tabs = $(this.TABS.replace(/{{label}}/, label));

    $('#main-content-elements').wrap($wrapper);
    $('#fixed-elements').prepend($tabs).tabs().tabs('paging', {
      follow: true,
      followOnSelect: true
    });
  },

  // Creates a fixed element tab.
  createTab: function(element_id, label) {
    var $fixed_elements = $('#fixed-elements'),
        $tab;

    $('> ul', $fixed_elements).append('<li><a href="#fixed-element-' + element_id + '">' + label + '</a></li>');
    $tab = $('<div id="fixed-element-' + element_id + '" class="sortable-elements" />');
    $fixed_elements.append($tab);
    $fixed_elements.tabs().tabs('refresh');
    $fixed_elements.tabs('option', 'active', $('#fixed-elements > div').index($tab));
  },

  removeTab: function(element_id) {
    var $fixed_elements = $('#fixed-elements');

    $fixed_elements.find('a[href="#fixed-element-' + element_id + '"]').parent().remove();
    $fixed_elements.find('div#fixed-element-' + element_id).remove();
    $fixed_elements.tabs().tabs('refresh');
  }
};
