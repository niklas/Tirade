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
