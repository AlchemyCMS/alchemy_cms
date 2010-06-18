var SortableTree = Class.create({
  initialize: function(element, options) {
    this.element = $(element);
    this.root = new SortableTree.Node(this, null, element, options);
		this.isSortable = false;
  },
  
  toggleSortable: function() {
    this.isSortable ? this.setUnsortable() : this.setSortable();
  },
  
  setSortable: function() {
    Element.addClassName(this.root.element, 'sortable');
		this.root.setSortable();
		this.isSortable = true;
  },

	setUnsortable: function() {
    Element.removeClassName(this.root.element, 'sortable');
		this.root.setUnsortable();
		this.isSortable = false;
	},
  
  find: function(element) {
    return this.root.find($(element));
  },

	unmark_all: function() {
    this.root.unmark();
	}
});

SortableTree.Node = Class.create({
  initialize: function(tree, parent, element, options) {
    this.tree = tree;
    this.parent = parent;
    this.element = $(element);

    this.options = Object.extend({
      tagName: 'LI',
      containerTagName: 'UL',
			droppable: {},
			draggable: {}
    }, options || {});

    this.droppable_options = Object.extend({
      onHover:      function(drag, drop, overlap){ this.onHover(drag, drop, overlap); }.bind(this),
      onDrop:       function(drag, drop, event){ this.onDrop(drag, drop, event); }.bind(this), 
      overlap:      'vertical',
      hoverclass:   'drop_hover'
    }, options.droppable);

    this.draggable_options = Object.extend({
      ghosting: true,
      revert: true,
      constraint:  'vertical',
      reverteffect: function(element, top_offset, left_offset) {
		    element.setStyle({left: '0px', top:  '0px'});
				// would be so cool to be able to use this. but it leaves a backgroundColor
				// style property on the element which overwrites the class' value
				// (i.e. the drop marker) and apperently can't be removed anymore (?)
				// new Effect.Highlight(element, { startcolor: '#FFFF99' })
      }
    }, options.draggable);

    this.initChildren();
  },
  
  id: function() {
    if (!this._id) {
      var match = this.element.id.match(/^[\w]+_([\d]*)$/);
      this._id = encodeURIComponent(match ? match[1] : null);
    }
    return this._id;
  },
  
  previousSibling: function() {
    var pos = this.parent.children.indexOf(this);
    return pos > 0 ? this.parent.children[pos - 1] : null;
  },
  
  initChildren: function() {
    this.children = [];  
    var container = this.findContainer(this.element);
    if(container){
      $A(container.childNodes).each(function(child) {
        if(this.acceptTagName(child)) {
          this.children.push(new SortableTree.Node(this.tree, this, child, this.options));
        }
      }.bind(this));
    }
  },

  acceptTagName: function(element) {
    return element.tagName && element.tagName.toUpperCase() == this.options.tagName;
  },

  setSortable: function() {
    Droppables.add(this.element, this.droppable_options);
    this.draggable = new Draggable(this.element, this.draggable_options);
    this.children.each(function(child) { child.setSortable(); });
  },

  setUnsortable: function() {
		Droppables.remove(this.element);
		this.draggable.destroy();
    this.children.each(function(child) { child.setUnsortable(); });
  },
  
  find: function(element) {
    if(element == this.element) return this;
    for(var i = 0; i < this.children.length; i++) {
      var node = this.children[i].find(element);
      if(node) return node; 
    }
  },

  findContainer: function(element) {
    if(element.tagName != this.options.containerTagName) {
      element = $A(element.childNodes).detect(function(node) { 
        return node.tagName == this.options.containerTagName;
      }.bind(this));
    }
    return element;
  },

  findOrCreateContainer: function(element) {
    var container = this.findContainer(element);
    if(!container) {
      container = document.createElement(this.options.containerTagName);
      element.appendChild(container);
    }
    return container;
  },

  onHover: function(drag, drop, overlap) {		
		if(this.canContainChildren(drop)) {
		  this.dropPosition = overlap < 0.33 ? 'bottom' : overlap > 0.77 ? 'top' : 'insert';
		} else {
			this.dropPosition = overlap < 0.5 ? 'bottom' : 'top';
		}
    this.mark(drop);
		// $('log').update('hovering: ' + drop.tagName + ': ' + drop.id + "<br />" + 
		//                 'classes: ' + drop.className + "<br />" + 
		// 							  'dropPosition: ' + this.dropPosition)
  },	

	canContainChildren: function(element) {
		if(this.options.droppable.container) {
			return element.match(this.options.droppable.container);
		}
		return true;
	},

  onDrop: function(drag, drop, event) {
    drag = this.tree.find(drag);
    drop = this.tree.find(drop);

		// i.e. don't do anything if it's a toplevel node and has been dropped on "itself"
		// another way around this could be to change scriptaculous to affect() a node
		// when it has been dropped on itself
		if(drop.parent || this.dropPosition == 'insert') { 
	    switch(this.dropPosition) {
	      case 'top':    drop.parent.insertBefore(drag, drop); break;
	      case 'bottom': drop.parent.insertBefore(drag, drop.nextSibling()); break;
	      case 'insert': this.insertBefore(drag, this.firstChild()); break;
	    }
		}

    if(this.options.onDrop) this.options.onDrop(drag, drop, event);
  },

  mark: function(element, position) {
		this.tree.unmark_all();
    Element.addClassName(element, 'drop_' + this.dropPosition);
  },

  unmark: function() {
    ['drop_top', 'drop_bottom', 'drop_insert'].each(function(classname){
      Element.removeClassName(this.element, classname);
    }.bind(this));
		this.children.each(function(child) { child.unmark(); });
  },
  
  to_params: function(name) {
		name = name || this.tree.element.id;
    var leftNode = this.previousSibling();
    return name + '[' + this.id() + '][parent_id]=' + this.parent.id() + '&' + 
           name + '[' + this.id() + '][left_id]=' + (leftNode ? leftNode.id() : ''); // null
  },
  
  firstChild: function() {
    return this.children.length > 0 ? this.children[0] : null;
  },
  
  previousSibling: function() {
    var pos = this.parent.children.indexOf(this);
    return pos > 0 ? this.parent.children[pos - 1] : null;
  },
  
  nextSibling: function() {
    var pos = this.parent.children.indexOf(this);
    return pos + 1 < this.parent.children.length ? this.parent.children[pos + 1] : null;    
  },
  
  removeChild: function(node) {
    this.children.splice(this.children.indexOf(node), 1);
    node.element.parentNode.removeChild(node.element);
  },
  
  insertBefore: function(node, sibling) {
		if(node == sibling) return;
		
		node.parent.removeChild(node);
    node.parent = this;
    var pos = sibling ? this.children.indexOf(sibling) : this.children.length;
    this.children.splice(pos, 0, node);

    this.findOrCreateContainer(this.element).insertBefore(node.element, sibling ? sibling.element : null);
  }
});