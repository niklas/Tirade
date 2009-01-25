(function($){
  $.fn.hasOneEditor = function(options) {
    var defaults = {
    };
    var options = $.extend(defaults, options);

    return this.each(function() {
      list = $(this);
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

  $.fn.hasManyEditor = function(options) {
    var defaults = {
    };
    var options = $.extend(defaults, options);
    return this.each(function() {
      var list = $(this)
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
          $(ui.draggable).clone().appendTo(list);
        }
      });
      $('li', list).livequery(function() {
        $(this).hasManyEditorElement();
      });
    });
  };

  $.fn.hasManyEditorElement = function(options) {
    var defaults = {
    };
    var options = $.extend(defaults, options);
    this.each(function() {
      var item = $(this);
      var id = item.resourceId();
      item.parent()
          .removeClass('empty')
          .siblings('input[@type=hidden][@value=empty]')
            .clone().attr('value',id).appendTo(item);

      item
        .find('img.association').remove().end()
        .appendDom(Toolbox.Templates.removeButton)
        .find('img.remove').click(function(event) {
          item.remove();
          Toolbox.last(' ul.list:not(:has(li))').addClass('empty');
        });
    });
  };

})(jQuery);

