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

    if ($('toolbox')) {
      this.win = $('toolbox').win;
    } else {
      this.win = new Window({
        title: 'Toolbox', 
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
  pushContent: function(content,options) {
    var options = Object.extend({
      class:      'frame',
      href:       '/dashboard',
      title:      '[No Title]'
    }, options || { });
    frame = new Element('div', options);
    frame.insert(content);
    this.scroller.insert({bottom: frame});
    this.win.setTitle(frame.title);
    this.markLastFrame();
  },
  slideLeft: function() {
    new Effect.Move(this.scroller, {duration: 0.3, mode: 'relative', y: 0, x: -this.win.width})
    this.markLastFrame();
  },
  slideRight: function() {
    new Effect.Move(this.scroller, {duration: 0.3, mode: 'relative', y: 0, x: this.win.width})
    this.markLastFrame();
  },
  updateLastFrame: function(content) {
    frame = this.frames().last();
    frame.update(content);
    frame.resetBehavior();
  },
  setStatus: function(status) {
    this.win.setStatusBar(status);
  },
  frames: function() {
    return this.scroller.getElementsBySelector('div.frame');
  },
  syncLastFrame: function() {
    if ( last_frame = Toolbox.frames().last() ) {
      this.win.setTitle(last_frame.title);
      this.markLastFrame();
    }
  },
  pop: function() {
    new Effect.Move(this.scroller, {
      duration: 0.3, mode: 'relative', 
      y: 0, x: this.win.width,
      afterFinish: function(scroller) {
        Toolbox.frames().last().remove();
        Toolbox.syncLastFrame();
      }
    })
  },
  removeSecondLast: function() {
    this.frames().reverse()[1].remove();
    this.markLastFrame();
  },
  markLastFrame: function() {
    this.frames().each( function(frame) {
      frame.removeClassName('last');
    } )
    this.frames().last().addClassName('last');
  }
});

Tirade.Toolbox.Frame = Behavior.create({
  initialize: function() {
    this.url = this.element.getAttribute('href');
    this.title = this.element.title;
    if (this.element.id == 'dashboard') return;
    if (this.element.getElementsBySelector('ul.linkbar a.back').size() > 0) return;
    if (first_linkbar = this.element.getElementsBySelector('ul.linkbar').first()) {
      new Insertion.Top(
        first_linkbar, $li( $a( {class: 'back', href: '#'}, 'Back' )  )
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


