var Toolbox = {
  defaults: {
  },
  open: function(options) {
    return this.findOrCreate(options);
  },
  findOrCreate: function(options) {
    options = $.extend({}, this.defaults, options)
    if ( this.element().length == 0 ) {
      Toolbox.minHeight = 400;
      $('body').appendDom(Toolbox.Templates.toolbox);
      $('body #toolbox_body')
        .dialog({
          closeOnEscape: false,
          minHeight: Toolbox.minHeight,
          minWidth: 300,
          title: 'Toolbox Dialog',
          dragStart: Toolbox.overflowsOff,
          dragStop:  Toolbox.overflowsOn,
          drag: Toolbox.sync.sideBarPosition,
          close: Toolbox.close,
          resizeStop: Toolbox.sync.all
        }).parent().attr('id', 'toolbox');

      this.sideBarVisible = false;
      this.setup();
      Toolbox.sync.sideBar();

      $('<div />')
        .addClass('frame')
        .text("preparing Toolbox..")
        .data('url', '/dashboard')
        .data('title', 'Dashboard')
        .data('action', 'show')
        .data('controller', 'user_session')
        .appendTo( this.content() );

      $.tirade.history.sync();
      this.frameCount = 1;
      this.currentFrameIndex = 0;
      this.expireBehaviors();
      this.applyBehaviors();
      this.element().show();
    };
    this.setSizes();
    switch (options.mode) {
      case 'tiled': 
        this.tile();
        break;
      case 'maximized':
        this.maximize();
        break;
    }
    return this.element();
  },
  setup: function() {
    this.body = $('div#toolbox_body');

    this.footer = $('<div />')
      .addClass('ui-widget-header ui-corner-all footer')
      .attr('id', 'toolbox_footer')
      .insertAfter(Toolbox.body);

    this.header = this.element().find('> div.ui-widget-header.ui-dialog-titlebar:first').addClass('header');

    this.sideBar = $('<div />')
      .addClass('sidebar left ui-corner-all')
      .attr('id', 'toolbox_sidebar')
      .appendTo('body');

    this.history = $.tirade.history.build()
      .appendTo(Toolbox.sideBar);

    this.clipboard = $('<ul />')
      .addClass('clipboard list records ui-widget-content ui-corner-all')
      .appendTo(Toolbox.sideBar);

    this.sideBarActions = $('<div />')
      .addClass('actions ui-widget-header ui-corner-all ui-helper-clearfix')
      .appendTo(Toolbox.sideBar);

    this.pickFocusButton = $.ui.button({class: 'toggle edit grid', text: 'Toggle Edit Layout', icon: 'suitcase'})
      .appendTo(Toolbox.sideBarActions)
      .click( $.tirade.focus.pick );

    this.refreshPageButton = $.ui.button({class: 'refresh_page', text: 'Refresh Page', icon: 'arrowrefresh-1-w'})
      .click(function(e) { 
        var page = $('body > div.page_margins > div.page');
        var url = page.metadata().url || window.location.pathname;
        page.beBusy('refreshing');
        $.get(url);
        e.stopPropagation(); e.preventDefault();
        return false;
      })
      .appendTo(Toolbox.sideBarActions);

    this.toggleSideBarButton = $.ui.button({class: 'toggle-sidebar', icon: 'power', text: 'toggle sidebar'})
      .mousedown(function(ev) { ev.stopPropagation(); })
      .click(function(event) {
         if (Toolbox.sideBarVisible) {
           Toolbox.sideBarOff()
           Toolbox.toggleSideBarButton.removeClass('ui-state-active');
         } else {
           Toolbox.sideBarOn()
           Toolbox.toggleSideBarButton.addClass('ui-state-active');
         }
         return false;
      })
      .appendTo(Toolbox.footer);

    this.leftButtons = $('<span/>')
      .addClass('buttons left')
      .prependTo(Toolbox.header);
    this.rightButtons = $('<span/>')
      .addClass('buttons right')
      .prependTo(Toolbox.header);

    this.backButton = $.ui.button({icon: 'circle-triangle-w', text: 'back', class: 'back'})
      .click( function(event) { 
        event.preventDefault();
        Toolbox.pop();
        return false;
      })
      .prependTo(Toolbox.leftButtons);

    this.maximizeButton = $.ui.button({icon: 'arrow-4-diag', text: 'maximize', class: 'size-max' })
      .click(Toolbox.maximize).appendTo(Toolbox.rightButtons);

    this.normalSizeButton = $.ui.button({icon: 'pin-s', text: 'normalize', class: 'size-normal' })
      .click(Toolbox.unmaximize).appendTo(Toolbox.rightButtons);

    this.tileButton = $.ui.button({icon: 'triangle-2-e-w', text: 'tile', class: 'size-tile' })
      .click(Toolbox.tile).appendTo(Toolbox.rightButtons);

    this.closeButton = this.header.find('a.ui-dialog-titlebar-close')
      .prependTo(Toolbox.rightButtons);

    Toolbox.setWindowState('normal');

    this.elements = $('#toolbox, #toolbox_sidebar');
  },
  applyBehaviors: function() {
    var self = this;
    self.body.serialScroll({
      step: 1, cycle: false,
      lazy: true,
      event: null,
      items: 'div.frame',
      onBefore: Toolbox.overflowsOff,
      onAfter:  function() {
        Toolbox.overflowsOn();
        $.tirade.history.sync();
      },
      axis: 'x',
      duration: 555
    })

    self.body.bind('prev.serialScroll', self.refreshBackButton );
    self.body.bind('next.serialScroll', self.refreshBackButton );
    self.body.bind('notify.serialScroll', self.setTitle );
    self.refreshBackButton();

    $('> div.content > div.frame', self.body).livequery(
      function() { 
        $(this).frameInToolbox();
        self.frameCount = self.frames().length;
      },
      function() { 
        $.tirade.history.sync();
        self.frameCount = self.frames().length;
        if (self.currentFrame().length == 0) {
          self.currentFrameIndex = self.frameCount - 1;
        }
      }
    );

    // Scroll to selected accordion section
    // TODO needed?
    //this.accordion(' h3.selected').livequery(function() { 
    //  var s = $(this);
    //  $.timer(300,function(timer) {
    //    timer.stop();
    //    Toolbox.accordion().scrollTo(s, 500);
    //    $(this).addClass('scrolled');
    //  })
    //});

    // Init and Auto-Refresh the Dashboard
    //Toolbox.frameByHref('/dashboard').refresh();
    //$.timer(60 * 1000,function(timer) {
    //  if (!Toolbox.element()) {
    //    timer.stop();
    //  } else {
    //    if (!Toolbox.minimized) {
    //      Toolbox.frameByHref('/dashboard').refresh();
    //    }
    //  }
    //});



    // search results items
    this.last(' di.association dd div.live_search div.search_results ul.list li').livequery(function() {
      item = $(this);
      association_list = item.parents('div.live_search').siblings('ul.list.ui-droppable:first');
      item 
        .find('img.association').remove().end()
        .appendDom(Toolbox.Templates.addButton)
        .find('img.add').click(function(event) {
          if (association_list.parents('di.association:first').is('.one')) {
            association_list.find('li').remove();
          }
          item.clone().appendTo(association_list);
        })
    });


    // Double click selectable attributes to edit them
    // FIXME what?
    //this.last(' di.selectable').livequery(function() {
    //  $(this).dblclick( function() {
    //    $(this).parents('div.frame').find('ul.linkbar li a.edit:first').click();
    //  });
    //});



    this.last(' a.toggle_live_search').livequery('click', function(e) {
      e.preventDefault();
      $(this).siblings('.live_search').toggle();
    });

    // Ajax callbacks
    this.element()
      .ajaxStop(function() {
        Toolbox.element().unBusy()
      });

    this.setSizes();
  },
  expireBehaviors: function() {
    $('> div.content > div.frame:last', this.body).expire();
    $('> div.content > div.frame', this.body).expire();
    this.last(' di.association dd div.live_search div.search_results ul.list li').expire()
    this.last(' a.toggle_live_search').expire();
  },
  setSizes: function() {
    /* this.scroller().height( this.bodyHeight() );
    this.busyBox().height( this.bodyHeight() );
    this.accordion().height(
      Toolbox.body().height() - Toolbox.linkBar().height()
      ); */
  },
  bodyHeight: function() {
    return this.element().height() - this.decorationHeight()
  },
  decorationHeight: function() {
    return this.element(' > div.head').height() + this.element(' > div.foot').height()
  },
  push: function(frame_html,options) {
    var frame = $(frame_html);
    if (!frame.hasClass('frame')) {
      frame = frame.wrap('<div class="frame"></div>').parent();
    }
    frame.appendTo( this.content() );
    $.tirade.history.append(frame);
    this.goto(frame);
  },
  goto: function(frame) {
    if (frame.jquery) {
      var $frame = $(frame).closest('.frame');
      var index = Math.max(0, this.frames().index($frame));
    } else {
      var $frame = this.frames().eq(index);
      var index = frame;
    }
    this.currentFrameIndex = index;
    return this.body.trigger('goto', [index] );
  },
  error: function( content, options ) {
    var options = jQuery.extend({
      href:       'error',
      title:      'Error',
      class:      'error'
    }, options);
    this.push(content, options);
  },
  // 
  surrounds: function(position) {
    return(
      Toolbox.element().surrounds(position) ||
      Toolbox.sideBar.surrounds(position)
    );
  },
  pop: function() {
    if ( this.frameCount > 1 ) {
      $('body').applyRoles();
      this.refreshBackButton();
      this.prev();
      setTimeout( this.removeLastFrame, 500 );
    }
  },
  removeLastFrame: function() {
    var frame = Toolbox.last().remove();
    Toolbox.element().trigger('toolbox.frame.removed', frame);
    History.pop();
    Toolbox.refreshBackButton();
  },
  refreshBackButton: function() {
    if ( Toolbox.frameCount > 1 )
      Toolbox.backButton.removeClass('ui-state-disabled')
    else
      Toolbox.backButton.addClass('ui-state-disabled')
  },
  overflowsOff: function() {
    Toolbox.overflows().css('overflow', 'visible');
    return true;
  },
  overflowsOn: function() {
    Toolbox.overflows().css('overflow', '');
    return true;
  },
  overflows: function() {
    return Toolbox
      .frames()
      .add('div.frame .accordion')
      .add('div.frame .accordion_content')
  },
  popAndRefreshLast: function() {
    this.last().prev().refresh();
    this.pop();
  },
  popAndUpdateWith: function(content,options) {
    var options = jQuery.extend({ content: content }, options);
    this.last().prev().update(options);
    this.pop();
  },
  updateLastFrame: function(content,options) {
    var options = jQuery.extend({
      title:      '[No Title]'
    }, options);
    this.last().html(content);
    this.setTitle(options.title);
  },
  setTitle: function(title) {
    if (!title) {
      title = Toolbox.currentFrame().data('title') || 
          Toolbox.currentFrame().attr('title');
    }
    return $('span#ui-dialog-title-toolbox_body').html( title );
  },
  setClipboard: function(html) {
    return this.clipboard.html(html);
  },
  setStatus: function(status) {
    return this.element('> div.foot span.status').html(status);
  },
  setBusyText: function(text) {
    return this.busyBox('> span.message').html(text);
  },
  beBusy: function(message) {
    return this.element().beBusy(message);
  },
  unBusy: function() {
    return this.element().unBusy();
  },
  every: function(selector, todo) {
    $(selector, this.element()).livequery(todo)
  },
  beExclusiveDroppable: function() {
    if ( !this.exclusiveDroppable ) {
      this.otherDroppables()
        .droppable("disable")
        .removeClass('hover')
        .removeClass('drop-invite');
      this.exclusiveDroppable = true;
    }
  },
  unExclusiveDroppable: function() {
    if ( this.exclusiveDroppable ) {
      this.otherDroppables().droppable("enable");
      this.exclusiveDroppable = false;
    }
  },
  beGhost: function() {
    if ( !this.ghosted ) {
      this.elements.stop().animate({opacity: 0.42, duration: 500});
      this.ghosted = true;
    }
  },
  unGhost: function() {
    if ( this.ghosted ) {
      this.elements.stop().animate({opacity: 1, duration: 500});
      this.ghosted = false;
    }
  },
  frames: function(rest) {
    return this.content('> div.frame'+(rest||''));
  },
  frameByHref: function(href,rest) {
    return this.frames('[href=' + href + ']'+(rest||''))
  },
  currentFrame: function() {
    return this.frames().eq(this.currentFrameIndex);
  },
  scroller: function(rest) {
    return this.element('> div.body'+(rest||''));
  },
  content: function(rest) {
    return this.scroller('> div.content' +(rest||''));
  },
  last: function(rest) {
    return this.frames(':last' +(rest||''));
  },
  head: function(rest) {
    return this.element('> div.ui-dialog-titlebar:first'+(rest||''))
  },
  busyBox: function(rest) {
    return this.element('> div.busy'+(rest||''))
  },
  element: function(rest) {
    return $('div#toolbox' +(rest||''));
  },
  next: function() {
    return this.body.trigger('next');
  },
  prev: function() {
    return this.body.trigger('prev');
  },
  close: function() {
    Toolbox.expireBehaviors();
    Toolbox.sideBar.remove();
    Toolbox.element().remove();
    $('body #toolbox_body').remove();
    $('div.active').removeClass('active');
    return true;
  },
  otherDroppables: function() {
    return this.element().siblings(':not(#toolbox_sidebar)').find('.ui-droppable')
  },
  accordion: function() {
    return this.last(' div.accordion')
  },
  openSectionByName: function(name) {
    selector = '[name='+name+']:not(.selected)';
    if (this.accordion().find(selector).length!=0) {
      return this.accordion().accordion('activate', selector);
    }
  },
  openPreferredSection: function() {
    if (name = this.lastSectionName ||
      this.last().prev().find('.selected.ui-accordion-header').attr('name')) {
      return this.openSectionByName(name);
    }
  },
  saveActive: function(element) {
    if (element) {
      if (name = element.attr('name')) {
        this.activeSectionName = name;
      } else {
        this.activeSectionName = element.find('.selected.ui-accordion-header').attr('name');
      }
    } else {
      this.saveActive( this.last() )
    }
  },
  minimize: function() {
    if (this.minimized) {
      this.unminimize();
    } else {
      this.oldHeight = this.element().height();
      this.sideBarOff(function() {
        Toolbox.element().animate(
          { height: Toolbox.decorationHeight()-1}, 
          { duration: 700, complete: function() {
            Toolbox.body.hide();
            Toolbox.sideBar.hide();
          }}
        )
      });
      this.minimized = true;
    }
  },
  sideBarOn: function(after) {
    if (this.sideBarVisible) 
      return this.sideBar;
    this.sideBarVisible = true;
    return this.sideBar.show().animate(
      { left: (Toolbox.element().position().left - Toolbox.sideBar.width())},
      { duration: 500, complete: after }
    )
  },
  sideBarOff: function(after) {
    if (!this.sideBarVisible)  // And if it's already off?
      return this.sideBar;   //  - I just walk away!
    this.sideBarVisible = false;
    return this.sideBar.animate(
      { left: Toolbox.element().position().left},
      { duration: 500, complete: after }
    );
  },
  sideBarToggle: function(after) {
    if (this.sideBarVisible)
      return this.sideBarOff(after)
    else
      return this.sideBarOn(after)
  },
  linkBar: function() {
    return(Toolbox.last(' ul.linkbar'));
  },
  linkBarOn: function(after) {
    if (this.linkBar().css('top') != '0px') {
      var h = this.linkBar().height();
      this.last().animate({paddingTop: h, height: this.bodyHeight() - h}, {duration: 500 })
        .find('ul.linkbar') .animate({top:'0px'}, { duration: 300 });
    }
  },
  linkBarOff: function(after) {
    if (this.linkBar().css('top') == '0px') {
      var h = this.linkBar().height();
      this.last() .animate({paddingTop: '0', height: this.bodyHeight() }, { duration: 500 })
        .find('ul.linkbar').animate({top: -(2*h)}, {duration: 300 });
    }
  },
  unminimize: function() {
    if (!this.minimized) {
      this.minimize();
    } else {
      Toolbox.body.show();
      Toolbox.setSizes();
      this.element().animate(
        { height: this.oldHeight || 400}, 
        { complete: function() { Toolbox.sideBarOn() }}
      );
      this.minimized = false;
    }
  },
  storeSizeAndPosition: function() {
    this.element()
      .data('height',   this.element().height())
      .data('width',    this.element().width())
      .data('position', this.element().position())
  },
  maximize: function() {
    if (Toolbox.windowState == 'normal') Toolbox.storeSizeAndPosition();
    if (Toolbox.windowState == 'tiled') {
      $('body').stop().animate( {paddingRight: 0}, 'slow', 'linear', $.tirade.focus.sync );
    }

    Toolbox.toggleSideBarButton.addClass('ui-state-disabled');
    
    Toolbox.sideBar.stop().animate(
      {height: '98%', width: '30%'},
      'slow', 'linear', function() { Toolbox.sync.sideBarPosition(); Toolbox.sideBarOn();}
    );
    Toolbox.element().stop().animate(
      {height: '98%', width: '66%', top: '1%', left: '33%'},
      'slow', 'linear', function() { Toolbox.sync.frames(); }
    );
    Toolbox.setWindowState('maximized');
  },
  unmaximize: function() {
    var position = Toolbox.element().data('position');
    if (Toolbox.windowState == 'tiled') {
      $('body').stop().animate( {paddingRight: 0}, 'slow', 'linear', $.tirade.focus.sync );
    }
    Toolbox.toggleSideBarButton.removeClass('ui-state-disabled');
    Toolbox.element().stop().animate({
      height: Toolbox.element().data('height'), 
      width:  Toolbox.element().data('width'), 
      top: position.top, 
      left: position.left
      },
      'slow', 'linear', function() { Toolbox.sync.frames(); Toolbox.sync.sideBar() }
    );
    Toolbox.setWindowState('normal');
  },
  tile: function() {
    if (Toolbox.windowState == 'normal') Toolbox.storeSizeAndPosition();
    Toolbox.toggleSideBarButton.addClass('ui-state-disabled');
    Toolbox.element().stop().animate(
      {height: '50%', width: '30%', top: '1%', left: '69%'},
      'slow', 'linear', Toolbox.sync.frames
    );
    Toolbox.sideBar.stop().animate(
      {height: '45%', width: '30%', top: '54%', left: '69%' },
      'slow', 'linear');
    $('body').stop().animate( {paddingRight: '33%'}, 'slow', 'linear', $.tirade.focus.sync);
    Toolbox.setWindowState('tiled');
  },
  setWindowState: function(state) {
    this.windowState = state;
    switch (state) {
      case 'normal':
        this.maximizeButton.removeClass('ui-state-disabled');
        this.normalSizeButton.addClass('ui-state-disabled');
        this.tileButton.removeClass('ui-state-disabled');
        break;
      case 'maximized':
        this.maximizeButton.addClass('ui-state-disabled');
        this.normalSizeButton.removeClass('ui-state-disabled');
        this.tileButton.removeClass('ui-state-disabled');
        break;
      case 'tiled':
        this.maximizeButton.removeClass('ui-state-disabled');
        this.normalSizeButton.removeClass('ui-state-disabled');
        this.tileButton.addClass('ui-state-disabled');
        break;
    }
  },
  bottomLinkBar: function(rest) {
    if (this.last('>ul.bottom_linkbar').length == 0) {
      this.last().appendDom(Toolbox.Templates.bottomLinkBar);
    };
    return this.last('>ul.bottom_linkbar' + (rest||''));
  },

  sync: {
    /* if we resize manually (maximize, tile) */
    body: function() {
      Toolbox.body.css({ height: 0, minHeight: 0, width: 'auto' });
      var dialogHeight = Math.max( Toolbox.element().height(), Toolbox.minHeight);
      var nonContentHeight = Toolbox.element().css({height: 'auto'}).height();
      Toolbox.body.css({
        minHeight: Math.max(dialogHeight - nonContentHeight, 0),
        height: Math.max(dialogHeight - nonContentHeight, 0)
      })
    },
    frames: function() {
      Toolbox.sync.body();
      Toolbox.sync.scroller();
    },
    scroller: function() {
      if (Toolbox.last().length > 0) Toolbox.body[0].scrollLeft = Toolbox.last()[0].offsetLeft;
    },
    sideBar: function() {
      Toolbox.sync.sideBarSize();
      Toolbox.sync.sideBarPosition();
    },
    sideBarPosition: function() {
      if (Toolbox.sideBarVisible) {
        Toolbox.sideBar[0].style.left = (Toolbox.element().position().left - Toolbox.sideBar.width()) + 'px';
        Toolbox.sideBar[0].style.top =  (Toolbox.element().position().top + 42) + 'px';
      } else {
        Toolbox.sideBar[0].style.left = (Toolbox.element().position().left) + 'px';
        Toolbox.sideBar[0].style.top =  (Toolbox.element().position().top + 42) + 'px';
      }
    },
    sideBarSize: function() {
      Toolbox.sideBar.width(  Toolbox.element().width() * 0.7 );
      Toolbox.sideBar.height( Toolbox.element().height() * 0.9 );
    },
    all: function() {
      Toolbox.sync.frames();
      Toolbox.sync.sideBar();
    }
  },

};


Toolbox.Templates = {
  addButton: [ 
    { tagName: 'img', src: '/images/icons/small/plus.gif', class: 'association add' } 
    ],
  removeButton: [
    { tagName: 'img', src: '/images/icons/small/x.gif', class: 'association remove' }
  ],
  toolbox: [
    { tagName: 'div', id: 'toolbox_body', class: 'body', childNodes: [
      { tagName: 'div', class: 'content ui-helper-clearfix', id: 'toolbox_content' }
    ]},
  ],
}

jQuery.fn.update = function(options) {
  var options = jQuery.extend({ title: '[No Title]' }, options);
  $(this)
    .attr('title',options.title)
    .html(options.content);
  Toolbox.setTitle();
  return $(this);
}
jQuery.fn.refresh = function() {
  var href = $(this).closest('.frame').data('url');
  if (href) {
    if (href.match(/\?/)) {
      href = href + '&refresh=1'
    } else {
      href = href + '?refresh=1'
    }
    $.ajax({
      url: href,
      type: 'GET'
    });
  }
}

jQuery.fn.useToolbox = function(options) {
  var defaults = {
    mode: 'normal',
    start: function() {}
  };
  return this.each(function() {
    var options = $.extend(defaults, options);
    if (options.icon) { $(this).uiIcon(icon); }
    if ( $(this).hasClass('without_toolbox') ) return; /* next ? */
    if ( $(this).hasClass('ui-uses-toolbox') ) return; /* next ? */
    if ( $(this).hasClass('tiled') ) options.mode = 'tiled';
    if ( $(this).hasClass('maximized') ) options.mode = 'maximized';
    $(this).resourcefulLink().opensToolbox(options);
  });
};

jQuery.fn.opensToolbox = function(options) {
  var defaults = {
    mode: 'normal'
  };

  return this.each(function() {
    var options = $.extend(defaults, options);
    $(this).addClass('ui-uses-toolbox').click(function() {
      Toolbox.findOrCreate(options);
      Toolbox.beBusy('Loading');
    });
  });
};

jQuery.fn.uiIcon = function(icon) {
  return $(this).each(function() {
    var $a = $(this);
    var $span = $('<span />')
      .addClass('ui-icon ui-icon-' + icon)
      .html( $a.html() )
    $a.attr('title', $a.attr('title') || $a.text())
      .html( $span )
      .addClass('ui-corner-all')
      .hover(
         function() { $(this).addClass('ui-state-hover'); },
         function() { $(this).removeClass('ui-state-hover'); }
       );
  });
};

jQuery.fn.frameInToolbox = function(options) {
  var defaults = {
  };
  var options = $.extend(defaults, options);
  return $(this).each(function() {
    var frame = this;
    var $frame = $(this);

    $frame.attr('role', 'frame');

    var meta = $frame.metadata();
    if (meta.href) {
      Toolbox.setTitle(meta.title);
      $frame
        .data('url', meta.href)
        .data('title', meta.title)
        .data('action', meta.action)
        .data('controller', meta.controller)
        .data('resource_name', meta.resource_name);
    }

    var $linkbar = $('ul.linkbar', frame);

    if ($linkbar.length) {
      $linkbar
        .addClass('ui-widget-header ui-corner-bottom')
        .find('a.ok')
          .click(function(e) {
            e.preventDefault();
            Toolbox.pop();
            return false;
          }).uiIcon('circle-check')
        .end();

      switch(meta.action) {
        case 'index':
          $.tirade.resourceful.newButton(meta.resource_name).opensToolbox().appendTo($linkbar);
          break;
        case 'show':
          $.tirade.resourceful.editButton(meta.resource_name, meta.id).opensToolbox().appendTo($linkbar);
          $.tirade.resourceful.deleteButton(meta.resource_name, meta.id).opensToolbox().appendTo($linkbar);
          break;
      }
    }

    $('div.accordion', frame).livequery(function() { 
      active = 0;
      if (name = Toolbox.activeSectionName) { 
        active = '[name=' + name + ']' 
      };
      $(this).accordion({ 
        header: 'h3.accordion_toggle', 
        selectedClass: 'selected',
        clearStyle: true,
        active: active
      })
      .bind("accordionchange", function(event, ui) { /* FIXME WTF is this? */
        if (ui.newHeader) {
          Toolbox.saveActive(ui.newHeader);
          //Toolbox.accordion().scrollTo(ui.newHeader, 500);
        }
      });
    })
    $('div.live_search input.search_term', frame).livequery(function() {
      var field = $(this);
      $(this).attr("autocomplete", "off").typeWatch({
        wait: 500,
        captureLength: 2,
        callback: function(val) {
          $.ajax({
            data: { 'search[term]' : encodeURIComponent(val) },
            url: field.attr('href')
          });
        }
      })
    });
    $('div.live_search.polymorphic select.polymorph_search_url', frame).livequery(function() { 
      var field = $(this);
      $(this).change(function() {
        $(this).siblings('input.search_term:first')
          .attr('href',field.val())
          .val('');
      })
    });
   /* TODO Context Page only per head ? */
    $('form', frame).livequery(function() { $(this).formInFrameInToolbox() });

  });
};

jQuery.fn.formInFrameInToolbox = function(options) {
  var defaults = {
  };
  var options = $.extend(defaults, options);
  return $(this).each(function() {
    var form = this;
    var $form = $(this);

    form.action += '.js';

    if ($form.is('.edit_rendering')) $form.editRenderingFormInFrameInToolbox();
    if ($form.is('.new_image.with_flash')) $form.newImageFormInFrameInToolbox();

    $('textarea.markitup.textile').markItUp(myTextileSettings);
    $('textarea:not(.markitup)').each(function() {
      if ( !$(this).data('hasElastic') )
        $(this).elastic().data('hasElastic', true);
    });
    $('di.association.one dd > ul.list', form).livequery(function() { $(this).hasOneEditor() });
    $('di.association.many dd > ul.list', form).livequery(function() { $(this).hasManyEditor() });

    $form.find(':submit')
      .addClass('ui-corner-all')
      .addClass('ui-state-default')
      .hover(
         function() { $(this).addClass('ui-state-hover'); },
         function() { $(this).removeClass('ui-state-hover'); }
       );

    if ($form.closest('.frame').data('action') == 'edit') {
      $form.preview();
    }
    
    $form.ajaxForm({
      dataType: 'script',
      beforeSubmit: function() {
        Toolbox.beBusy("submitting " + $form.parents('div.frame').attr('title'))
      }
    });

  });
};

jQuery.fn.newImageFormInFrameInToolbox = function(options) {
  var defaults = {
  };
  var options = $.extend(defaults, options);
  return $(this).each(function() {
    var form = $(this);
    $('<a/>').attr('href', '#').text("Go").click( function() { form.uploadifyUpload()  }).appendTo(form.parent());
    $('<a/>').attr('href', '#').text("Clear").click( function() { form.uploadifyClearQueue()  }).appendTo(form.parent());
    form.uploadify({
      uploader: '/flash/uploadify.swf',
      multi: true,
      script: Routing.images_path({
        '_tirade-v2_session' : encodeURIComponent(Toolbox.cookie)
      }),
      scriptData: {
        authenticity_token: encodeURIComponent(form.parent().find('span.rails-auth-token').text())
      },
      method: 'POST',
      fileDataName: form.find(':input[type=file]:first').attr('name'),
      simUploadLimit: 1,
      buttonText: 'Browse',
      cancelImg: '/images/icons/small/x.gif',
    });
  });
};

jQuery.fn.editRenderingFormInFrameInToolbox = function(options) {
  var defaults = {
  };
  var options = $.extend(defaults, options);
  return $(this).each(function() {
    var form = $(this);
    renderingAssignmentFormUpdate = function (e) {
      form.find('h3.what + dl')
        .find('> di:not(.assignment)').hide()
          .find(':input').disable();
      form.find('di.association.one.content .live_search').hide();
      form.find('div.scopes').hide().find(':input').disable();
      form.find('div.scopes .define :input').hide();
      form.find('div.scopes .define a.create_scope').hide();
      switch (form.find('select#rendering_assignment').val()) {
        case 'none':
          break;
        case 'fixed':
          form.find('di.association.one.content').show().find('input.association_id, input.association_type').enable();
          break;
        case 'by_title_from_trailing_url':
          form.enableField('content_type');
          break;
        case 'scope':
          var t = form.enableField('content_type').val();
          var scope = form.find('div.scopes.' + t).show();
          scope.find(' > di :input').enable();  /* enable non-filtering scopes like order etc */
          break;
      }
    }
    renderingAssignmentFormUpdate();
    form.find('select#rendering_assignment').change( renderingAssignmentFormUpdate );
    form.find('select#rendering_content_type').change( renderingAssignmentFormUpdate );

    $('<a href="#" class="remove">Remove</a>').appendTo(form.find('div.pool di dt'));

    form.find('a.add').unbind('click').click( function(ev) {
      var link = $(ev.target);
      var define = link.parents('.define');
      var meta = define.metadata();
      var pool = define.siblings('div.pool');

      define.find(':input').show();
      var select_column = define.find('select[name=select_column]');
      var select_comparison = define.find('select[name=select_comparison]');
      var ok = define.find('.create_scope').show();

      select_column.find('option').remove();
      $.each(meta.columns, function() {
        $('<option value ="' + this.name + '">' + this.name +'</option>').appendTo(select_column)
      })

      var updateComparisons = function() {
        select_comparison.find('option').remove();
        $.each(meta.comparisons[ select_column.val() ], function() {
          $('<option value ="' + this + '">' + this +'</option>').appendTo(select_comparison)
        }) 
      }

      select_column.unbind('change').change( updateComparisons );
      updateComparisons();

      ok.click( function(ev) {
        var scope_name = select_column.val() + '_' + select_comparison.val();
        var scope = pool.find('di.' + scope_name).clone()
        scope
          .find(':input').enable().end()
          .find('a.remove').click(function() { scope.remove() }).end()
          .insertAfter(define);
        ok.hide();
        define.find(':input').hide();
        ev.preventDefault();
        return false;
      });

    });
  });
};

jQuery.ui.button = function(options) {
  var defaults = {
    hover: true,
    icon: 'help',
    text: 'Help',
    href: '#',
    selectable: false
  };
  var options = $.extend(defaults, options);
  var button = $('<a/>')
    .addClass('ui-corner-all ui-button ' + options.class)
    .attr('href', options.href)
    .attr('role', 'button');
  if (options.hover) button.hover(
       function() { button.addClass('ui-state-hover'); },
       function() { button.removeClass('ui-state-hover'); }
     );
  $('<span/>')
    .addClass('ui-icon ui-icon-' + options.icon)
    .text(options.text)
    .attr('title', options.title || options.text)
    .appendTo(button);
  if (!options.selectable) button.disableSelection();
  return button
};

