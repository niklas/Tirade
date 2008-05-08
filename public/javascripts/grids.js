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

Remote.LinkWithToolbox = Behavior.create({
  initialize: function() {
    return new Remote.Link(this.element, { 
      onCreate: function() {
        new Toolbox('footer', 'blabla', {'cornerRadius': 10})
      }
    })
  },
  onmouseover: function() {
    parent_div = this.element.parentNode.parentNode;
    parent_div.addClassName('hover');
  },
  onmouseout: function() {
    parent_div = this.element.parentNode.parentNode;
    parent_div.removeClassName('hover');
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
        constraint: 'vertical',
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

SearchResults = Behavior.create({
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
