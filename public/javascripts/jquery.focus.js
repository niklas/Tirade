(function($) {
  window.Focus = $.focusable = function(action, new_options) {
    // events.trigger('event');
  };

  $.extend( $.focusable, {
    defaults: {
      parent: 'div',
      children: 'div',
      side_children: null
    },
    frameClasses: 'focus ui-widget',
    current: null,
    exists: function() {
      return $.focusable.frames().length > 0;
    },
    open: function() {
      var classes = $.focusable.frameClasses;
      $.focusable.frameBottom = $('<div/>')
        .addClass('bottom ui-corner-bottom')
        .addClass(classes)
        .attr('role', 'focus')
        .hide()
        .appendTo($('body'));

      $.focusable.frameLeft = $('<div/>')
        .addClass('left ui-corner-left')
        .addClass(classes)
        .attr('role', 'focus')
        .hide()
        .appendTo($('body'));

      $.focusable.frameRight = $('<div/>')
        .addClass('right ui-corner-right')
        .addClass(classes)
        .attr('role', 'focus')
        .hide()
        .appendTo($('body'));

      $.focusable.frameTop = $('<div/>')
        .addClass('top ui-dialog ui-widget-content ui-corner-top')
        .addClass(classes)
        .attr('role', 'focus')
        .hide()
        .appendTo($('body'));

      $.focusable.titleBarTop = $('<div/>')
        .addClass('ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix')
        .attr('role', 'titlebar')
        .appendTo($.focusable.frameTop);

      $.focusable.backButton = $.ui.button({icon: 'circle-triangle-w', text: 'back', class: 'back'})
        .click( $.focusable.back )
        .appendTo($.focusable.titleBarTop);

      $.focusable.titleElement = $('<span/>')
        .addClass('ui-dialog-title title')
        .text('Title')
        .appendTo($.focusable.titleBarTop);

      var tabs = $('<div />').addClass('ui-tabs').hide();

      $.focusable.tabsTop = $('<ul />')
        .addClass('ui-tabs-nav ui-widget-header ui-helper-reset ui-corner-all ui-helper-clearfix')
        .appendTo( tabs.clone().appendTo($.focusable.frameTop) );

      $.focusable.tabsLeft = $('<ul />')
        .addClass('ui-tabs-nav ui-tabs ui-widget-header ui-helper-reset ui-corner-all ui-helper-clearfix')
        .appendTo( tabs.clone().appendTo($.focusable.frameLeft) );

      $.focusable.pickButton = $.ui.button({icon: 'suitcase', text: 'pick', class: 'pick'})
        .click( $.focusable.pick )
        .appendTo($.focusable.titleBarTop);
      $.focusable.showButton = $.ui.button({icon: 'circle-triangle-e', text: 'show', class: 'show with_toolbox'})
        .appendTo($.focusable.titleBarTop);

      $(window).bind('resize', $.focusable.sync);
      $('body').css('padding-top', '9em');
    },
    start: function() {
      $.focusable.on( $('.ui-focusable:first') );
    },
    stop: function() {
      $(window).unbind('resize', $.focusable.sync);
      $('body').animate({paddingTop: 0});
      return $.focusable.frames().remove();
    },
    on: function(element) {
      var e = $(element).closest('.ui-focusable');
      if (e.length == 0) return;
      if (!$.focusable.exists()) $.focusable.open();
      $.focusable.goto(e);
      return this;
    },
    goto: function(element) {
      var e =  $(element).closest('.ui-focusable');
      if (e.length == 0) return;
      $.focusable.current = e;
      var options = e.data('focusable:options');
      $.focusable.fillTopTabs( options.children ?  $(options.children, e) : []);
      $.focusable.fillLeftTabs( options.left_children ?  $(options.left_children, e) : []);
      $.focusable.title( e.attr('title') || e.typeAndId().type );
      $.focusable.showButton.attr('href', e.showUrl()  );
      // $.focusable.clearButtons();
      // $.focusable.setButtons(this.element.);
      $.focusable.sync();
    },
    pick: function(ev) {
      var clicker = $(this);
      clicker.addClass('ui-state-active');
      if (ev) ev.stopPropagation();
      $('body')
        .css('cursor', 'crosshair')
        .one('click', function(ev) {
          ev.stopPropagation();
          $.focusable.on( ev.target );
          $('body').css('cursor', 'auto');
          clicker.removeClass('ui-state-active');
          return false;
        });
      return(clicker);
    },
    back: function() {
      if (!$.focusable.exists()) return;
      var e = $.focusable.current;
      var options = e.data('focusable:options');
      if (options.parent) {
        var parent = e.parent().closest(options.parent).closest('.ui-focusable');
        if (parent.length == 1) {
          parent.trigger('tirade.focus');
        }
      }
    },
    sync: function() {
      var e = $.focusable.current;
      if (e.length == 0) return;

      var border = 5;
      var padding = 3;
      var left = e.offset().left;
      var top = e.offset().top;
      var eWidth = e.outerWidth({margin: true});
      var header = $.focusable.frameTop.width(eWidth).outerHeight();
      var dialogPadding = $.focusable.frameTop.outerWidth() - $.focusable.frameTop.width();

      $.focusable.frameTop.show().animate({
        top: top - header - padding, 
        left: left - border - padding, 
        width: eWidth + 2*border + 2*padding - dialogPadding
      });
      $.focusable.frameBottom.show().animate({
        top: top + e.height() + padding, 
        left: left - border - padding, 
        height: border,
        width: eWidth + 2*border + 2*padding
      });
      $.focusable.frameLeft.show().animate({
        top: top - header - padding, 
        left: left - border - padding, 
        width: border,
        height: e.height() + header + border + 2*padding
      });
      $.focusable.frameRight.show().animate({
        top: top - header - padding, 
        left: left + eWidth + padding, 
        width: border,
        height: e.height() + header + border + 2*padding
      });
    },
    title: function(new_title) {
      $.focusable.titleElement.text(new_title);
    },
    frames: function() {
      return $('body div.focus')
    },
    fillTopTabs: function(elements) { 
      return $.focusable.fillTabs( $.focusable.tabsTop, elements );
    },
    fillLeftTabs: function(elements) { 
      return $.focusable.fillTabs( $.focusable.tabsLeft, elements );
    },
    fillTabs: function(container, elements) {
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
          .text( $self.attr('title') || $self.typeAndId().type )
          .click(function() { $.focusable.goto($self) })
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
  });

  $.fn.focusable = function(action, options) {
    if (typeof(action) == 'object') {
      options = action;
    };
    return this
      .each(function() {
        e = $(this);
        //$.each(options, function(event, fn) {
        //  if (typeof(fn) == 'function')
        //    e.bind(event, fn);
        //});
        //e.trigger('event');
        options = $.extend({}, $.focusable.defaults, e.data('focusable:options'), options);
        e.data('focusable:options', options);
      })
      .addClass('ui-focusable')
      .bind('tirade.focus', function(event) {
        $.focusable.on(event.target);
        event.stopPropagation();
        return false;
      });
  };

  $( function() {
    $('div.page').focusable({parent: null, children: '>div.grid'});
    $('div.grid').focusable({parent: 'div.grid, div.page', children: '> * > div.grid,>div.grid', left_children: '>div.rendering'});
    $('div.rendering').focusable({parent: 'div.grid', children: null});
  });

})(jQuery);


