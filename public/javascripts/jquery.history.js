(function($) {
  if (!$.tirade) $.tirade = {};
  window.History = $.tirade.history = function(options) {
    return this;
  };
  $.extend( $.tirade.history, {
    build: function(options) {
      this.element = $('<ul />')
        .addClass('history list');
      return this.element;
    },
    sync: function() {
      var self = this;
      self.clear();
      Toolbox.frames().each(function() {
        self.append(this)
      });
    },
    append: function(frame) {
      var $frame = $(frame);
      return $('<li />')
          .addClass('item')
          .addClass('ui-state-default ui-corner-left ui-widget-content')
          .text( $frame.attr('title') )
          .hover(
            function() { $(this).addClass('ui-state-hover') },
            function() { $(this).removeClass('ui-state-hover') }
          )
          .click(function() { Toolbox.goto($frame); })
          .appendTo($.tirade.history.element);
    },
    clear: function() {
      return this.items().remove();
    },
    items: function() {
      return this.element.find('li')
    },
    pop: function() {
      return this.items().filter(':last').remove();
    }
  });
})(jQuery);


