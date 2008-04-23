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
          $a({href: edit_rendering_url({id: numeric_id_for(this.element)})},'edit')
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

