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
      Toolbox.body.bind('notify.serialScroll', function(event, index) {
        self.activate(index);
      });
      return this.element;
    },
    sync: function() {
      var self = this;
      self.clear();
      Toolbox.frames().each(function() {
        self.append(this);
      });
      self.activate(Toolbox.currentFrameIndex);
    },
    activate: function(index) {
      return this.items().removeClass('ui-state-active').eq(index || 0).addClass('ui-state-active');
    },
    append: function(frame) {
      var $frame = $(frame);
      return $('<li />')
          .addClass('item')
          .addClass('ui-state-default ui-corner-left ui-widget-content')
          .css('cursor', 'pointer')
          .html( $frame.data('title') || $frame.attr('title') )
          .hover(
            function() { $(this).addClass('ui-state-hover'); },
            function() { $(this).removeClass('ui-state-hover'); }
          )
          .click(function() { Toolbox.goTo($frame); })
          .appendTo($.tirade.history.element)
          .slideDown('fast');
    },
    clear: function() {
      return this.items().remove();
    },
    items: function() {
      return this.element.find('li');
    },
    pop: function() {
      return this.items().filter(':last').remove();
    }
  });
})(jQuery);


