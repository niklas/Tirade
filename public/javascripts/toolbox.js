Tirade = {};
Tirade.Toolbox = Class.create({ 
  initialize: function(options) {
    options = options || { };
    this.options = options;

    this.insertInto        = $$('body').first() ;
    this.width          = options.width || 400;
    this.height         = options.height || 500;
    this.top						= options.top || 140;
    this.left						= options.left || 240;

    this.titles = ['Dashboard'];

    if ($('toolbox')) {
      this.win = $('toolbox').win;
    } else {
      this.win = new Window({
        title: this.titles.first(), 
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
      window['Toolbox'] = this;
    }
    return true;
  },
  pushTitle: function(title) {
    this.titles.push(title);
    this.win.setTitle(this.titles.last());
  },
  pushContent: function(content) {
    frame = new Element('div', {class: 'frame'});
    frame.insert(content);
    this.scroller.insert({bottom: frame});
    new Effect.Move(this.scroller, {duration: 0.3, mode: 'relative', y: 0, x: -this.win.width})
  },
  updateLastFrame: function(content) {
    frame = this.scroller.getElementsBySelector('div.frame').last();
    frame.update(content);
    frame.resetBehavior();
  },
  popTitle: function() {
    this.titles.pop()
    this.win.setTitle(this.titles.last());
  },
  pop: function() {
    new Effect.Move(this.scroller, {
      duration: 0.3, mode: 'relative', 
      y: 0, x: this.win.width,
      afterFinish: function(scroller) {
        Toolbox.scroller.getElementsBySelector('div.frame').last().remove();
        Toolbox.popTitle();
      }
    })
  }
});

Tirade.Toolbox.Frame = Behavior.create({
  initialize: function() {
    if (this.element.id == 'dashboard') return;
    if (this.element.getElementsBySelector('ul.linkbar a.back').size() > 0) return;
    if (first_linkbar = this.element.getElementsBySelector('ul.linkbar').first()) {
      new Insertion.Top(
        first_linkbar,
        $li( $a( {class: 'back', href: '#'}, 'Back' )  )
      );
    }
      
  }
});

Tirade.Toolbox.Back = Behavior.create({
  onclick: function(event) {
    Event.stop(event);
    Toolbox.pop();
    return false;
  }
});

Tirade.Toolbox.Accordion = Behavior.create({
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


