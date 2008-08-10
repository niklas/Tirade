Toolbox = Class.create({ 
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
      new Insertion.Bottom( $('toolbox_content'), 
        $div({ id: 'scroller'},
          $div({ class: 'frame', id: 'dashboard'}, "TODO: Dashboard")
        )
      );
      this.scroller = $('scroller');
      this.win.setCloseCallback( function() {
        $$("div.active").each(function(value, index) {
          value.removeClassName("active"); 
          value.resetBehavior();
        });
        return(true);
      });
      this.win.showCenter();
    }
    window['toolbox'] = this;
    window['Toolbox'] = this;
  },
  push: function() {
    new Effect.Move(this.scroller, {duration: 0.5, mode: 'relative', y: 0, x: -this.win.width})
  },
  pop: function() {
    new Effect.Move(this.scroller, {
      duration: 0.5, mode: 'relative', 
      y: 0, x: this.win.width,
      afterFinish: function(scroller) {
        Toolbox.scroller.getElementsBySelector('div.frame').last().remove();
      }
    })
  }
});

Toolbox.Back = Behavior.create({
  onclick: function() {
    Toolbox.pop();
  }
});

Toolbox.Accordion = Behavior.create({
  initialize: function() {
    this.accordion = new Fx.Accordion(
      this.element.getElementsBySelector('*.accordion_toggle'),
      this.element.getElementsBySelector('*.accordion_content'),
      {
        display: 0,
        alwaysHide: true,
        onActive: function(toggler, i) {
          toggler.addClassName('accordion_toggle_active');
          element = this.elements[i];
          // reset height to auto, so that livesearches work again
          setTimeout(function() {
            element.style.height = "auto";
          },1000);
        },
        onBackground: function(toggler, element) {
          toggler.removeClassName('accordion_toggle_active');
        }

      }
    );

  }
});


