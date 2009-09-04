(function($){
  $.widget('ui.hasOneEditor', {
    _init: function() {
      var list = this.element;
      var o = this.options;
      list.droppable({
        accept: function(draggable) { 
          return(
            draggable.is(o.items) &&
            draggable.parent()[0] != list[0] &&
            draggable.typeAndId()
          );
        },
        hoverClass: 'drop-hover',
        activeClass: 'active-droppable',
        greedy: true,
        tolerance: 'pointer',
        drop: function(e,ui) {
          var item = $(ui.draggable);
          list.find(o.items).remove();
          item.clone().appendTo(list);
        }
      })
      .addClass(this.widgetBaseClass)
      .addClass('ui-corner-all')
      .addClass('empty');

      $(o.items, list[0]).livequery(
        function() {
          $(this).hasOneEditorElement();
          list.removeClass('empty');
        },
        function() {
          if (list.find(o.items).length == 0) list.addClass('empty');
        }
      );

    }
  })
  $.ui.hasOneEditor.defaults = {
    items: 'li.record'
  };

  /* Fills hidden input fields with id and type of dropped element */
  $.widget('ui.hasOneEditorElement', {
    _init: function() {
      var item = this.element;
      var o = this.options;
      var list = item.closest(o.list);
      if ( attrs = item.typeAndId() ) {
        list
          .siblings('input.association_id:first').val(attrs.id).end()
          .siblings('input.association_type:first').val(attrs.type).end()
      } else {
        item.remove();
        return;
      };
      item.find('a.association').remove();
      $.ui.button({icon: 'minus', text: 'remove', cssclass: 'association remove'})
        .click(function(event) {
          list
            .siblings('input.association_id:first').val('').end()
            .siblings('input.association_type:first').val('').end()
          item.remove();
          event.preventDefault(); event.stopPropagation();
        })
        .appendTo(item);
    }
  });
  $.ui.hasOneEditorElement.defaults = {
    list: 'ul.ui-hasOneEditor'
  };


  $.widget('ui.hasManyEditor', {
    _init: function() {
      var list = this.element;
      var o = this.options;
      list.droppable({
        accept: function(draggable) { 
          return(
            draggable.is(o.items) &&
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
      .addClass('empty')
      .siblings('input.association_id[type=hidden][value=empty]').disable();

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
    items: 'li.record'
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
          .clone().enable().attr('value',id).appendTo(item);

      item.find('a.association').remove();
      $.ui.button({icon: 'minus', text: 'remove', cssclass: 'association remove'})
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

