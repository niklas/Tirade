GridEditable = Behavior.create({
  initialize: function() {
    var me = this.element;
    new Insertion.Top(this.element, 
      $div(
        {class: 'admin'},
        [ 
          $a({href: edit_grid_url({id: this._numeric_id(this)})},'edit')
        ]
      )
    );
  },
  _numeric_id: function(me) {
    return(me.element.id.match(/(\d+)$/).first());
  }
});
