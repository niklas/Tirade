(function($) {

  /* Focusable Elements */
  $.widget('ui.focusable', {
    _init: function() {
      this.element.addClass('ui-focusable');
      if ($.tirade.focus.exists()) {
        this.focus();
      }
    },
    focus: function() {
      $.tirade.focus.on(this.element, this.options);
    }
  });
  $.ui.focusable.defaults = {
    parent: 'div',
    children: 'div',
    side_children: null,
    // this will point to focusable
    buttons: function() {},
    visit: function() {},
    leave: function() {}
  };


  if (!$.tirade) $.tirade = {};

  /* The one and only focus */
  $.tirade.focus = function(options) {
    this.prepare();
    return this;
  };
  $.extend( $.tirade.focus, {
    _open: function(element) {
      if (!element) element = $(this.root);
      this.element = $(element).filter(':first');
      var classes = this.frameClasses;
      /* Frame parts */
      this.frameBottom = $('<div/>')
        .addClass('bottom ui-corner-bottom')
        .addClass(classes)
        .attr('role', 'focus')
        .hide()
        .appendTo(this.element);

      this.frameLeft = $('<div/>')
        .addClass('left ui-corner-left')
        .addClass(classes)
        .attr('role', 'focus')
        .hide()
        .appendTo(this.element);

      this.frameRight = $('<div/>')
        .addClass('right ui-corner-right')
        .addClass(classes)
        .attr('role', 'focus')
        .hide()
        .appendTo(this.element);

      this.frameTop = $('<div/>')
        .addClass('top ui-dialog ui-widget-content ui-corner-top')
        .addClass(classes)
        .attr('role', 'focus')
        .hide()
        .appendTo(this.element);

      /* Title (Bar) */

      this.titleBarTop = $('<div/>')
        .addClass('ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix')
        .attr('role', 'titlebar')
        .appendTo(this.frameTop);


      this.titleElement = $('<span/>')
        .addClass('ui-dialog-title title')
        .text('Title')
        .appendTo(this.titleBarTop);

      /* Tabs*/

      var tabs = $('<div />').addClass('ui-tabs').hide();

      this.tabsTop = $('<ul />')
        .addClass('ui-tabs-nav ui-widget-header ui-helper-reset ui-corner-all ui-helper-clearfix')
        .appendTo( tabs.clone().appendTo(this.frameTop) );

      this.tabsLeft = $('<ul />')
        .addClass('ui-tabs-nav ui-tabs ui-widget-header ui-helper-reset ui-corner-all ui-helper-clearfix')
        .appendTo( tabs.clone().appendTo(this.frameLeft) );

      /* Buttons */

      this.leftButtons = $('<span />')
        .addClass('buttons left')
        .prependTo( this.titleBarTop );
      this.rightButtons = $('<span />')
        .addClass('buttons right')
        .prependTo( this.titleBarTop );

      this.pickButton = $.ui.button({icon: 'suitcase', text: 'pick', class: 'pick sticky'})
        .click( this.pick )
        .appendTo(this.leftButtons);

      this.showButton = $.ui.button({icon: 'circle-triangle-e', text: 'show', class: 'show with_toolbox sticky'})
        .appendTo(this.rightButtons);

      this.backButton = $.ui.button({icon: 'circle-triangle-w', text: 'back', class: 'back sticky'})
        .click( this.back )
        .prependTo(this.leftButtons);

      $(window).bind('resize', this.sync);
      this.element.css('padding-top', '9em');
    },
    frameClasses: 'focus ui-widget',
    current: null,
    currentOptions: null,
    exists: function() {
      return this._frames().length > 0;
    },
    start: function() {
      $('.ui-focusable:first').focusable('focus');
    },
    stop: function() {
      $(window).unbind('resize', this.sync);
      this.element.animate({paddingTop: 0});
      return this.frames().remove();
    },
    prepare: function() {
      if (!this.exists()) this._open();
    },
    root: 'body',
    on: function(element, options) {
      element = $(element);
      if (element.length == 0) return;
      this.prepare();
      this.goto(element, options);
      return this;
    },
    goto: function(element, options) {
      var e =  $(element);
      if (e.length == 0) return;
      if (this.current) {
        var callback = this.currentOptions.leave; 
        if ($.isFunction(callback)) callback.apply(this.current);
      }
      this.current = element;
      this.currentOptions = options;
      this._fillTopTabs( options.children ?  $(options.children, e) : []);
      this._fillLeftTabs( options.left_children ?  $(options.left_children, e) : []);
      this.title( e.attr('title') || e.metadata().title || e.typeAndId().type );
      this.showButton.attr('href', e.resourceURL()  );
      this._setButtons( options.buttons.call(e) );
      var callback = this.currentOptions.visit; 
      if ($.isFunction(callback)) callback.apply(this.current);
      // this.clearButtons();
      // this.setButtons(this.element.);
      this.sync();
    },
    pick: function(ev) {
      var clicker = $(this);
      clicker.addClass('ui-state-active');
      if (ev) ev.stopPropagation();
      $('body')
        .css('cursor', 'crosshair')
        .one('click', function(ev) {
          ev.stopPropagation();
          $(ev.target).closest('.ui-focusable').focusable('focus');
          $('body').css('cursor', 'auto');
          clicker.removeClass('ui-state-active');
          return false;
        });
      return(clicker);
    },
    back: function() {
      if (!$.tirade.focus.exists()) return;
      var e = $.tirade.focus.current;
      var options = $.tirade.focus.currentOptions;
      if (options.parent) {
        var parent = e
          .parent()
          .closest(options.parent)
          .closest('.ui-focusable');
        if (parent.length == 1) {
          parent.focusable('focus');
        }
      }
    },
    sync: function() {
      var self = $.tirade.focus;
      var e = self.current;
      if (!e || e.length == 0) return;

      var border = 5;
      var padding = 3;
      var left = e.offset().left;
      var top = e.offset().top;
      var eWidth = e.outerWidth({margin: true});
      ow = self.frameTop.width();
      var header = self.frameTop.width(eWidth).outerHeight();
      ow = self.frameTop.width(ow);
      var dialogPadding = self.frameTop.outerWidth() - self.frameTop.width();

      self.frameTop.show().animate({
        top: top - header - padding, 
        left: left - border - padding, 
        width: eWidth + 2*border + 2*padding - dialogPadding
      });
      self.frameBottom.show().animate({
        top: top + e.height() + padding, 
        left: left - border - padding, 
        height: border,
        width: eWidth + 2*border + 2*padding
      });
      self.frameLeft.show().animate({
        top: top - header - padding, 
        left: left - border - padding, 
        width: border,
        height: e.height() + header + border + 2*padding
      });
      self.frameRight.show().animate({
        top: top - header - padding, 
        left: left + eWidth + padding, 
        width: border,
        height: e.height() + header + border + 2*padding
      });
    },
    title: function(new_title) {
      this.titleElement.text(new_title);
    },
    _frames: function() {
      return $('body div.focus')
    },
    _fillTopTabs: function(elements) { 
      return this._fillTabs( this.tabsTop, elements );
    },
    _fillLeftTabs: function(elements) { 
      return this._fillTabs( this.tabsLeft, elements );
    },
    _fillTabs: function(container, elements) {
      if (!container) return;
      elements = $(elements).filter('.ui-focusable');
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
          .text( $self.attr('title') || $self.metadata().title || $self.typeAndId().type )
          .click(function() { $self.focusable('focus') })
          .wrap('<li></li>')
          .parent()
          .attr('rel', $self.attr('rel'))
          .addClass('ui-state-default')
          .appendTo( container );
        if (container.closest('.focus').is('.left'))
          link.height($self.height());
        else
          link.width($self.width() * 0.96);
      });
    },
    _setButtons: function(buttons) {
      this.rightButtons.find('a:not(.sticky)').remove();
      if (buttons && buttons.length > 0) {
        $(buttons).appendTo( this.rightButtons )
      }
    }
  });

  //Focus = $('body').tirade.focus();
})(jQuery);


