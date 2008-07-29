var Toolbox = Class.create({ 
  initialize: function(options) {
    options = options || { };
    this.options = options;

    this.insertInto        = $$('body').first() ;
    this.width          = options.width || 400;
    this.height         = options.height || 500;
    this.top						= options.top || 140;
    this.left						= options.left || 240;

    if ($('toolbox')) {
      this.win = $('toolbox').win;
    } else {
      this.win = new Window({
        title: "Toolbox", 
        id: 'toolbox',
        width: this.width, 
        height: this.height, 
        minWidth: 400,
        minHeight: 500,
        destroyOnClose: true, 
        minimizable: false,
        recenterAuto:false});
      this.win.setStatusBar("&nbsp;");
      new Insertion.Bottom(this.win.element, Builder.node('div', { id: 'toolbox_sidebar'}, 'sidebar' ));
      this.win.setCloseCallback( function() {
        $$("div.active").each(function(value, index) {
          value.removeClassName("active"); 
          value.resetBehavior();
        });
        return(true);
      });
      this.win.showCenter();
    }
  },
});


