var Focus = {
  on: function(element) {
    var element = this.element = $(element);
    if (element.length == 0) return;
    if (!this.exists()) this._createFrame();

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

    this.titleBar = $('<div/>')
      .addClass('ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix')
      .attr('role', 'titlebar')
      .appendTo(this.frameTop);

    this.title = $('<span/>')
      .addClass('ui-dialog-title title')
      .text('Title')
      .appendTo(this.titleBar);

    this.tabsTop = $('<ul />')
      .addClass('ui-tabs')
      .hide()
      .appendTo(this.frameTop);
    this.tabsLeft = $('<ul />')
      .addClass('ui-tabs')
      .hide()
      .appendTo(this.frameLeft);
  },
  exists: function() {
    return this.frames().length > 0
  },
  frames: function() {
    return $('body div.focus')
  },
  setTitle: function(text) {
    return this.title.text(text);
  }
};
