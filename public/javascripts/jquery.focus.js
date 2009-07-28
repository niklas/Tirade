var Focus = {
  on: function(element, options) {
    var e = $(element);
    if (e.length == 0) return;
    if (!this.exists()) this._createFrame();
    this.element = $(element);
    if (options.title) this.setTitle(options.title);

    if (options.tabs) { 
        this.setTopTabs(options.tabs)
    } else {
      this.tabBarTop.hide();
    }
    if (options.left_tabs) { 
      this.setLeftTabs(options.left_tabs)
    } else {
      this.tabsLeft.hide();
    }

    this.to(e);
    return this;
  },
  to: function(element) {
    this.element = $(element);
    this.updateFrame();
    return this;
  },
  off: function() {
    return this.frames().remove();
  },
  updateFrame: function() {
    if (this.element.length == 0) return;
    var element = this.element;
    var border = 5;
    var padding = 3;
    var left = element.offset().left;
    var top = element.offset().top;
    var header = this.frameTop.outerHeight();
    var dialogPadding = this.frameTop.outerWidth() - this.frameTop.width();

    this.frameTop.show().animate({
      top: top - header - padding, 
      left: left - border - padding, 
      width: element.width() + 2*border + 2*padding - dialogPadding
    });
    this.frameBottom.show().animate({
      top: top + element.height() + padding, 
      left: left - border - padding, 
      height: border,
      width: element.width() + 2*border + 2*padding
    });
    this.frameLeft.show().animate({
      top: top - header - padding, 
      left: left - border - padding, 
      width: border,
      height: element.height() + header + border + 2*padding
    });
    this.frameRight.show().animate({
      top: top - header - padding, 
      left: left + element.width() + padding, 
      width: border,
      height: element.height() + header + border + 2*padding
    });
  },
  _createFrame: function() {
    var classes = 'focus ui-widget';
    this.frameBottom = $('<div/>')
      .addClass('bottom ui-corner-bottom')
      .addClass(classes)
      .attr('role', 'focus')
      .hide()
      .appendTo($('body'));

    this.frameLeft = $('<div/>')
      .addClass('left ui-corner-left')
      .addClass(classes)
      .attr('role', 'focus')
      .hide()
      .appendTo($('body'));

    this.frameRight = $('<div/>')
      .addClass('right ui-corner-right')
      .addClass(classes)
      .attr('role', 'focus')
      .hide()
      .appendTo($('body'));

    this.frameTop = $('<div/>')
      .addClass('top ui-dialog ui-widget-content ui-corner-top')
      .addClass(classes)
      .attr('role', 'focus')
      .hide()
      .appendTo($('body'));

    this.titleBarTop = $('<div/>')
      .addClass('ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix')
      .attr('role', 'titlebar')
      .appendTo(this.frameTop);

    this.title = $('<span/>')
      .addClass('ui-dialog-title title')
      .text('Title')
      .appendTo(this.titleBarTop);

    this.tabBarTop = $('<div />')
      .addClass('ui-tabs ui-widget ui-widget-content  ui-corner-all')
      .hide()
      .appendTo(this.frameTop);

    this.tabsTop = $('<ul />')
      .addClass('ui-tabs-nav ui-widget-header ui-helper-reset ui-corner-all ui-helper-clearfix')
      .appendTo(this.tabBarTop);

    this.titleBarLeft = $('<div/>')
      .addClass('ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix')
      .attr('role', 'titlebar')
      .appendTo(this.frameLeft);

    this.tabsLeft = $('<ul />')
      .addClass('ui-tabs-nav ui-tabs ui-widget-header ui-helper-reset ui-corner-all ui-helper-clearfix')
      .hide()
      .appendTo(this.frameLeft);
  },
  exists: function() {
    return this.frames().length > 0
  },
  frames: function() {
    return $('body div.focus')
  },
  setTitle: function(text, place) {
    return this.title.text(text);
  },
  setTabs: function(html, place) {
    place = place || 'top'
    switch (place) {
      case 'top': 
        this.setTopTabs(html);
        break;
      case 'left': 
        this.setLeftTabs(html);
        break;
      default: return
    }
  },
  setTopTabs: function(html) {
    var element = Focus.element;
    this.tabsLeft.hide();
    this.tabsTop.html(html)
      .parent().show().end()
      .find('li')
        .each(function() {
          var link = $('a.show', this);
          var target = element.find('div.' + link.resourceIdentifier());
          link.click( function() { Focus.to(target) } );
          $(this).width(target.width());
        })
        .addClass('ui-state-default ui-corner-bottom')
        .find('a.show').useToolbox();
  },
  setLeftTabs: function(html) {
    var element = Focus.element;
    this.tabBarTop.hide();
    this.tabsLeft.html(html)
      .show()
      .find('li')
        .each(function() {
          var link = $('a.show', this);
          var target = element.find('div.' + link.resourceIdentifier());
          link.click( function() { Focus.to(target) } );
          $(this).height(target.height());
        })
        .addClass('ui-state-default ui-corner-left')
        .find('a.show').useToolbox();
  }
};
