/*jslint browser: true */
/*global jQuery, Toolbox  */

(function($) {
  if (!$.tirade) { $.tirade = {}; }
  window.History = $.tirade.history = function(options) {
    return this;
  };
  $.extend( $.tirade.history, {
    build: function(options) {
      var self = this;
      self.element = $('<ul />')
        .addClass('history list');
      Toolbox.body.bind('toolbox.frame.scrolled', function(event, index) {
        self.activate(index);
      });
      Toolbox.body.bind('toolbox.frame.remove', function(event, frame) {
        if (frame) {
          self.remove(frame);
        }
      });
      Toolbox.body.bind('toolbox.frame.create', function(event, frame) {
        self.appendOrUpdate(frame);
      });
      Toolbox.body.bind('toolbox.frame.refresh', function(event) {
        var frame = $(event.target).closest('.frame');
        self.appendOrUpdate(frame);
      });
      return this.element;
    },
    sync: function() {
      var self = this;
      self.clear();
      Toolbox.frames().each(function() {
        self.appendOrUpdate(this);
      });
      self.activate(Toolbox.currentFrameIndex);
    },
    activate: function(index) {
      return this.items().removeClass('ui-state-active').eq(index || 0).addClass('ui-state-active');
    },
    appendOrUpdate: function(frame) {
      var $frame = $(frame);
      var item = this.itemFor( $frame );
      if (!item.length) {
        item = $('<li />')
            .addClass('item')
            .addClass('ui-state-default ui-corner-left ui-widget-content')
            .hover(
              function() { $(this).addClass('ui-state-hover'); },
              function() { $(this).removeClass('ui-state-hover'); }
            )
            .click(function() { Toolbox.goTo($frame); })
            .appendTo($.tirade.history.element)
            .slideDown('fast');
      }
      this.fillItem(item, $frame);
      return item;

    },
    update: function($frame) {
      var item = this.itemFor($frame);
      if ( item.length ) {
        this.fillItem(item, $frame);
      }
    },
    remove: function($frame) {
      this.itemFor($frame).remove();
    },
    clear: function() {
      return this.items().remove();
    },
    items: function() {
      return this.element.find('li');
    },
    pop: function() {
      return this.items().filter(':last').remove();
    },
    fillItem: function(item, $frame) {
      item
        .html( $frame.metadata().title || $frame.data('title') || $frame.attr('title') )
        .attr('rel', $frame.attr('id') );
    },
    itemFor: function($frame) {
      return this.items().filter('[rel=' + $($frame.attr('id')) + ']');
    }
  });
})(jQuery);


