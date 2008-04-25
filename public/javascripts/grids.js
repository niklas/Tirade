GridEditable = Behavior.create({
  initialize: function() {
    var me = this.element;
    new Insertion.Top(this.element, 
      $div(
        {class: 'admin', id: 'admin_'+this.element.id},
        [ 
          $a({href: edit_grid_url({id: numeric_id_for(this.element)})},'edit')
        ]
      )
    );
  },
  // FIXME make use of this and export to a super class
  _numeric_id: function(me) {
    return(me.element.id.match(/(\d+)$/).first());
  }
});

ContentEditable = Behavior.create({
  initialize: function() {
    var me = this.element;
    new Insertion.Top(this.element, 
      $div(
        {class: 'admin', id: 'admin_'+this.element.id},
        [ 
          $a({href: rendering_url({id: numeric_id_for(this.element)})},'edit')
        ]
      )
    );
  },
  // FIXME make use of this and export to a super class
  _numeric_id: function(me) {
    return(me.element.id.match(/(\d+)$/).first());
  }
});

Toolbox = Behavior.create({
  initialize: function() {
    var element = this.element
    Event.observe(this.element, 'click', function(event) {
      Event.stop(event)
      new Toolbox('utilities', this.element.firstDescendant().href, {'cornerRadius': 10})
    }.bind(this));
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

Element.resetBehavior = function(element) { element.$$assigned = null };
