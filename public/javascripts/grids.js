GridEditable = Behavior.create({
  initialize: function() {
    var me = this.element;
    admin_id = 'admin_'+this.element.id;
    if (!$(admin_id)) {
      new Insertion.Top(this.element, 
        $div(
          {class: 'admin', id: admin_id},
          [ 
            $a({href: edit_grid_url({id: numeric_id_for(this.element)})},'edit')
          ]
        )
      );
      Event.addBehavior({'div.grid > div.admin > a': Remote.LinkWithToolbox})
    }
  },
  // FIXME make use of this and export to a super class
  _numeric_id: function(me) {
    return(me.element.id.match(/(\d+)$/).first());
  }
});

ContentEditable = Behavior.create({
  initialize: function() {
    var me = this.element;
    admin_id = 'admin_'+this.element.id;
    if (!$(admin_id)) {
      new Insertion.Top(this.element, 
        $div(
          {class: 'admin', id: admin_id},
          [ 
            $a({href: rendering_url({id: numeric_id_for(this.element)})},'edit')
          ]
        )
      );
      Event.addBehavior({'div.rendering > div.admin > a': Remote.LinkWithToolbox})
    }
  },
  // FIXME make use of this and export to a super class
  _numeric_id: function(me) {
    return(me.element.id.match(/(\d+)$/).first());
  }
});

var currently_hovered_div = null;

Remote.LinkWithToolbox = Behavior.create({
  initialize: function() {
    return new Remote.Link(this.element, { 
      onCreate: function() {
        new Toolbox('Toolbox', {'cornerRadius': 4, 
          'top': currently_hovered_div.offsetTop, 
          'left': (currently_hovered_div.offsetLeft + currently_hovered_div.offsetWidth)})
      }
    })
  },
  onmouseover: function() {
    parent_div = this.element.parentNode.parentNode;
    parent_div.addClassName('hover');
    currently_hovered_div = parent_div;
  },
  onmouseout: function() {
    parent_div = this.element.parentNode.parentNode;
    parent_div.removeClassName('hover');
    currently_hovered_div = null;
  }
});

SortableRenderings = Behavior.create({
  initialize: function() {
    this._createSortable();
    //Event.observe(this.element,'changed',function() { alert('changed') });
  },
  _createSortable: function() {
    Sortable.create(
      this.element, {
        dropOnEmpty: false,
        constraint: null,
        containment: false,
        tag: 'div',
        only: 'rendering',
        onUpdate: this._onOrdering
      }
    );
    //alert('sortable created for ' + this.element.id);
  },
  _onOrdering: function(element) {
    poststring = Sortable.serialize(element, {tag: 'div', name: 'renderings'});
    url = order_renderings_grid_url({ id: numeric_id_for(element) })
    new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:poststring});
  }
});

Element.addMethods({
    resetBehavior: function(element) {
      $(element).$$assigned = null;
    }
});

ContentSearchResults = Behavior.create({
  onclick: function(e) {
    var source = Event.element(e);
    Event.stop(e);
    return this._select(source);
  },
  _select: function(result) {
    if (match = result.id.match(/^(.+)_(\d+)$/)) {
      new Effect.Highlight('rendering_content_type');
      $('rendering_content_type').value = match[1].gsub(/_/,'-').capitalize().camelize();
      new Effect.Highlight('rendering_content_id');
      $('rendering_content_id').value = match[2];
    }
  }
});

AddableImages = Behavior.create({
  onclick: function(e) {
    var source = Event.element(e);
    Event.stop(e);
    return this._addToList(source.parentNode);
  },
  _addToList: function(image) {
    if (match = image.id.match(/^image_(\d+)$/)) {
      hiddenfield = $input({type: 'hidden', id: 'content[image_ids][]', name: 'content[image_ids][]', value: match[1]});
      $('pictures_list').appendChild(image);
      image.appendChild(hiddenfield);
    }
  }
});
RemovableImages = Behavior.create({
  onclick: function(e) {
    var source = Event.element(e);
    Event.stop(e);
    return this._removeFromList(source.parentNode);
  },
  _removeFromList: function(image) {
    if (match = image.id.match(/^image_(\d+)$/)) {
      if (confirm("Remove Image?")) {
        image.remove();
      }
    }
  }
});
