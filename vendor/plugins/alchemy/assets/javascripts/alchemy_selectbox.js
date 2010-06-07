var waSelectbox = Class.create({
  initialize: function(element) {
    var defaults = {
      update: {}
    };
    var options = Object.extend(defaults, arguments[1] || { });
    this.options = options;
    this.element = $(element);
    this.updateField = $(this.options.update);
    this.boxbody = this.element.select('div')[1];
    if (this.boxbody) {
      this.values = this.boxbody.select('a');
    }
    if (!waSelectbox.selects) {
      waSelectbox.selects = [];      
    }
    this.attachEvents();
  },

  attachEvents: (function() {
    Element.observe(document, "click", function(e) {
      if (this.clickedOutside(e)) {
        this.boxbody.hide();
      }
    }.bind(this));
    Element.observe(this.element, "click", function(e) {
      e.stop();
      this.openBox();
    }.bind(this));
    if (this.values) {
      this.values.each(function(v) {
        Element.observe(v, 'click', this.handleSelect.bind(this));
      }.bind(this));      
    }
    Element.observe(this.element, 'wa_select:select', function(e) {
      this.selectValue(e.memo.value);
    }.bind(this));
    // attaching custom function to select element. so now we can select a value by calling select.waSelectValue(value)
    this.element.selectValue = function(value) {
      this.selectValue(value);
    }.bind(this);
    
    waSelectbox.selects.push(this);
    
  }),
  
  clickedOutside: (function(e) {
    var box_x1 = this.element.cumulativeOffset().left;
  	var box_x2 = box_x1 + this.element.getWidth();
  	var box_y1 = this.element.cumulativeOffset().top;
  	var box_y2 = box_y1 + this.element.getHeight();
  	if ( (e.pointerX() < box_x1) || (e.pointerX() > box_x2) || (e.pointerY() < box_y1) || (e.pointerY() > box_y2) ) {
  		return true;
  	}
  }),
  
  openBox: (function() {
    this.boxbody.toggle();
  }),
  
  handleSelect: (function(e) {
    e.stop();
    var element = e.findElement();
    var selected_value = element.readAttribute('rel');
    this.selectValue(selected_value);
    this.boxbody.hide();
  }),
  
  selectValue: function(value) {
    var selected_value = this.findValue(value);
    if (selected_value) {
      this.updateSelectLink(selected_value);
      this.setSelected(selected_value);
      this.updateField.value = selected_value.readAttribute('rel');
      if (this.options.afterSelect) {
        this.options.afterSelect(value);
      }      
    }
  },

  setSelected: (function(value) {
    this.selected_value = value;
    this.values.each(function(value) {
      value.removeClassName('selected');
    });
    this.selected_value.addClassName('selected');
  }),
  
  updateSelectLink: (function(element) {
    element.up().previous().down().down('.alchemy_selectbox_link_content').update(element.innerHTML);
  }),
  
  findValue: (function(value) {
    return this.values.detect(function(v) {
      return v.readAttribute('rel') == value;
    });
  })

});

waSelectbox.findSelectById = function(id) {
  return waSelectbox.selects.detect(function(s) {
    return s.element.identify() == id;
  })
}
