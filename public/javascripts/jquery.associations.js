(function($){
  $.fn.hasOneEditor = function(options) {
    var defaults = {
    };
    var options = $.extend(defaults, options);

    return this.each(function() {
      var list = $(this);
      list.droppable({
        accept: function(draggable) { 
          return(
            draggable.is('li') &&
            draggable.parent()[0] != list[0] &&
            draggable.typeAndId()
          );
        },
        hoverClass: 'hover',
        activeClass: 'active-droppable',
        greedy: true,
        tolerance: 'touch',
        drop: function(e,ui) {
          var item = $(ui.draggable);
          list.find('li').remove();
          item.clone().appendTo(list);
        }
      });
      $('li', list).livequery(function() {
        $(this).hasOneEditorElement();
      });
    });
  }

  $.fn.hasOneEditorElement = function(options) {
    var defaults = {
    };
    var options = $.extend(defaults, options);
    this.each(function() {
      var item = $(this);
      if ( attrs = item.typeAndId() ) {
        item.parent()
          .removeClass('empty')
          .siblings('input.association_id:first').val(attrs.id).end()
          .siblings('input.association_type:first').val(attrs.type).end()
      } else {
        item.remove();
      };
     item 
      .find('img.association').remove().end()
      .appendDom(Toolbox.Templates.removeButton)
      .find('img.remove').click(function(event) {
        item.parent()
          .siblings('input.association_id:first').val('').end()
          .siblings('input.association_type:first').val('').end()
        item.remove();
        Toolbox.last(' ul.list:not(:has(li))').addClass('empty');
      });
    });
  };

  $.widget('ui.hasManyEditor', {
    _init: function() {
      var list = this.element;
      var o = this.options;
      list.droppable({
        accept: function(draggable) { 
          return(
            draggable.is(o.accept) &&
            draggable.parent()[0] != list[0] &&
            draggable.typeAndId()
          );
        },
        hoverClass: 'drop-hover',
        activeClass: 'active-droppable',
        greedy: true,
        tolerance: 'pointer',
        drop: function(e,ui) {
          ui.draggable.clone().appendTo(list);
        }
      })
      .addClass(this.widgetBaseClass)
      .addClass('ui-corner-all')
      .addClass('empty');

      $(o.items, list[0]).livequery(
        function() {
          $(this).hasManyEditorElement();
          list.removeClass('empty');
        },
        function() {
          if (list.find(o.items).length == 0) list.addClass('empty');
        }
      );

    }
  })
  $.ui.hasManyEditor.defaults = {
    items: 'li.record',
    accept: 'li.record'
  };

  $.widget('ui.hasManyEditorElement', {
    _init: function() {
      var item = this.element;
      var o = this.options;
      var list = item.closest(o.list);
      var id = item.resourceId();

      /* Add hidden input field with id, template is an empty one */
      list
        .removeClass('empty')
        .siblings('input.association_id[type=hidden][value=empty]')
          .clone().attr('value',id).appendTo(item);

      item.find('a.association.remove').remove();
      $.ui.button({icon: 'minus', text: 'remove', class: 'association remove'})
        .click(function(event) {
          item.remove();
          event.preventDefault(); event.stopPropagation();
        })
        .appendTo(item);
    }
  });
  $.ui.hasManyEditorElement.defaults = {
    list: 'ul.ui-hasManyEditor'
  };

})(jQuery);

