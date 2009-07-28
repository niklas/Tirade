var Focus = {
  on: function(element, options) {
    var e = $(element);
    if (e.length == 0) return;
    if (!this.exists()) this._createFrame();
    this.to(e);
    return this;
  },
  start: function() {
    $('div.page:first').trigger('tirade.focus');
  },
  to: function(element) {
    if (!this.exists()) return;
    this.element = $(element);
    var options = this.element.data('focus-options');
    this.tabsToTop( options.children ?  $(options.children, this.element) : []);
    this.tabsToLeft( options.left_children ?  $(options.left_children, this.element) : []);
    this.setTitle( this.element.attr('title') || this.element.typeAndId().type );
    this.updateFrame();
    return this;
  },
  off: function() {
    $('body').animate({paddingTop: 0});
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

    this.backButton = $.ui.button({icon: 'circle-triangle-w', text: 'back', class: 'back'})
      .click( this.back )
      .appendTo(this.titleBarTop);

    this.title = $('<span/>')
      .addClass('ui-dialog-title title')
      .text('Title')
      .appendTo(this.titleBarTop);

    var tabs = $('<div />').addClass('ui-tabs').hide();

    this.tabsTop = $('<ul />')
      .addClass('ui-tabs-nav ui-widget-header ui-helper-reset ui-corner-all ui-helper-clearfix')
      .appendTo( tabs.clone().appendTo(this.frameTop) );

    this.tabsLeft = $('<ul />')
      .addClass('ui-tabs-nav ui-tabs ui-widget-header ui-helper-reset ui-corner-all ui-helper-clearfix')
      .appendTo( tabs.clone().appendTo(this.frameLeft) );
    $('body').css('padding-top', '5em');
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
  back: function() {
    if (!Focus.exists()) return;
    var options = Focus.element.data('focus-options');
    if (options.parent) {
      var parent = Focus.element.parent().closest(options.parent);
      if (parent.length == 1) {
        parent.trigger('tirade.focus');
      }
    }
  },
  tabsToTop: function(elements) {
    this.tabsTo( Focus.tabsTop, elements );
  },
  tabsToLeft: function(elements) {
    this.tabsTo( Focus.tabsLeft, elements );
  },
  tabsTo: function(container, elements) {
    if (elements.length == 0) {
      container.parent().hide();
      return;
    }
    container
      .find('li').remove().end()
      .parent().show();
    return elements.each( function() {
      var $self = $(this);
      var link = $('<a />')
        .attr('href', '#')
        .text( $(this).attr('title') || $(this).typeAndId().type )
        .click(function() { $self.trigger('tirade.focus') })
        .wrap('<li></li>')
        .parent()
        .addClass('ui-state-default')
        .appendTo( container );
      if (container.closest('.focus').is('.left'))
        link.height($self.height());
      else
        link.width($self.width());
    });
  }
};


$.fn.focusable = function(options) {
  var defaults = {
    parent: 'div',
    children: 'div',
    side_children: null
  };
  var options = $.extend(defaults, options);

  return $(this)
    .data('focus-options', options)
    .addClass('ui-focusable')
    .bind('tirade.focus', function(event) {
      Focus.on(event.target);
      event.stopPropagation();
      return false;
    });
};

$( function() {
  $('div.page').focusable({parent: null, children: '>div.grid'});
  $('div.grid').focusable({parent: 'div.grid, div.page', children: '> * > div.grid,>div.grid', left_children: '>div.rendering'});
  $('div.rendering').focusable({parent: 'div.grid', children: null});
});
