/*
 * Builds up the interface for tirade, needs jquery and more than one jquery plugin
 */






ChiliBook.recipeFolder = 'javascripts/syntax/'

$(function() {
  // Auto preview
  $.fn.preview = function() {
    var url = $.string( $(this).attr('action')  )
      .sub(/\.js$/, function(match) { return "/preview"+match }).str;
    var form = $(this);
    var fetchPreview = function(data) {
      $.ajax({
        url: url, 
        type: 'POST',
        data: data || form.formSerialize()
      });
    };
    Toolbox.scroller().one('prev', function() {
      fetchPreview(form.find('input[name=authenticity_token],input[name=_method],input[name=context_page_id]').serialize()); /* reset old state */
    });

    form.formWatch({callback: fetchPreview});
  }

  // Apply roles classes from cookie (for body etc.)
  $.fn.applyRoles = function() {
    var e = $(this);
    if ($.cookie("roles")) {
      $(e[0].className.split(/ /)).each(function(i,cls) {
        if (cls.match(/role_\S*/))
          e.removeClass(cls)
      });
      $($.cookie("roles").split(/&/)).each(function(i,role) {
        e.addClass('role_' + role);
      });
      e.addClass('cookie_roles');
    }
    return(e);
  }

  $.fn.surrounds = function(position) {
    me = $(this);
    meoff = me.offset();
    return(
        meoff.top < position.top && meoff.left < position.left &&
        meoff.top + me.height() > position.top &&
        meoff.left + me.width() > position.left
    );
  }

  $.fn.beBusy = function(message) {
    var div = $('<div/>')
      .addClass('busy')
      .hide();

    $('<span />')
      .addClass('message')
      .html(message || 'Loading')
      .appendTo(div);
    $('div.busy', this).remove();

    return div.appendTo(this).fadeIn(500);
  }
  $.fn.unBusy = function() {
    return $('div.busy', this).remove();
  }

  $.ajaxSetup({
    dataType: 'script',
    beforeSend: function(request) {
      request.setRequestHeader("Tirade-Page", $('div.page').resourceId() )
    }
  });

  $.metadata.setType( 'attr', 'data' );

  $('a.login').livequery(function() { $(this).useToolbox(); });
  $('a.with_toolbox').livequery(function() { $(this).useToolbox(); });

  $('code.html').livequery(function() { $(this).chili() });
  $('code.liquid').livequery(function() { $(this).chili() });


  /* Resourceful Links in Toolbox */
  $('ul.records li.record > a.show').livequery(function() { $(this).uiIcon('circle-triangle-e').addClass('ui-state-highlight').useToolbox(); });
  $('ul.list li > a.index').livequery(function() { $(this).uiIcon('circle-triangle-e').addClass('ui-state-highlight').useToolbox(); });
  $('ul.records li.record > a.edit').livequery(function() { $(this).uiIcon('pencil').useToolbox(); });
  $('dd.record > a.show').livequery(function() { $(this).uiIcon('circle-triangle-e').useToolbox(); });
  //$('div#toolbox > div.body > div.content > div.frame a.new').livequery(function() { $(this).uiIcon('plus').useToolbox(); });
  //$('div#toolbox > div.body > div.content > div.frame a.edit').livequery(function() { $(this).uiIcon('pencil').useToolbox(); });
  //$('div#toolbox > div.body > div.content > div.frame a.destroy').livequery(function() { $(this).uiIcon('trash').useToolbox(); });
  //$('div#toolbox_sidebar a.show').livequery(function() { $(this).uiIcon('circle-triangle-e').useToolbox(); });
  $('div#toolbox > div.body > div.content ul.tree.tree_root').livequery(function() { 
    $('div.node:not(:has(span.handle)):not(.page)', this).livequery( function() {
      $(this).append( $('<span>drag</span>').addClass('handle'))
    });
  });

  /* 
   * Toolbox Drag+Drop
   */
  $('ul.records > li.record, dl > di > dd.record').livequery(function() {
    $(this)
    .addClass('ui-widget-content ui-corner-all ui-helper-clearfix')
    .draggable({ 
      helper: 'clone', 
      zIndex: 9000, 
      appendTo: 'body',
      scroll: true,
      cursor: 'crosshair',
      cursorAt: {top: -1, left: -1},
      drag: function(e,ui) {
        if (Toolbox.surrounds(ui.absolutePosition)) {
          Toolbox.beExclusiveDroppable();
          Toolbox.unGhost();
        } else {
          Toolbox.unExclusiveDroppable();
          Toolbox.beGhost();
        };
      },
      stop: function(e,ui) {
        Toolbox.unExclusiveDroppable();
        Toolbox.unGhost();
      }
    });
  });

  $('ul.list, ul.records, dl.records').livequery(function() { $(this).listOfItems() });

  /*
   * Clipboard
   */
  $('div#toolbox_sidebar ul.clipboard').livequery(function() {
    var list = $(this);
    list.droppable({
      accept: function(draggable) { 
        return(
          draggable.is('li, dd.record') &&
          draggable.parent()[0] != list[0]
        );
      },
      hoverClass: 'drop-hover',
      activeClass: 'active-droppable',
      greedy: true,
      tolerance: 'touch',
      drop: function(e,ui) {
        $.ajax({
          url: Routing.clipboard_url(),
          data: {id: $(ui.draggable).resourceIdentifier()},
          type: 'POST'
        });
      }
    });
  });
  $('div#toolbox_sidebar ul.clipboard li').livequery(function() {
    var item = $(this);
    item.find('a.association').remove();
    $.ui.button({icon: 'circle-close', text: 'remove', cssclass: 'association remove'})
      .click(function(event) { 
        item.remove(); 
        $.ajax({
          url: Routing.clipboard_url(),
          data: {id: item.resourceIdentifier()},
          type: 'DELETE'
        });
      })
      .appendTo(item);
  });
  $('body').applyRoles();


  /* TODO: move to acts_as_custom_configurable */
  $('form ul.define_options').livequery(function() {
    var list = $(this);
    $.ui.button({icon: 'circle-plus', text: 'remove', cssclass: 'add option'})
      .click(function() {
        list.find('li:last').clone().removeClass('dummy').appendTo(list);
        return false;
      })
      .prependTo(list);
  });
  $('form ul.define_options li:not(.dummy)').livequery(function() {
    var item = $(this);
    $.ui.button({icon: 'circle-close', text: 'remove', cssclass: 'association remove'})
      .click(function() { item.remove(); return false; })
      .prependTo(item);
  });


});
