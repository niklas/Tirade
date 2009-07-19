/*
 * Builds up the interface for tirade, needs jquery and more than one jquery plugin
 */




// Auto preview
jQuery.fn.preview = function() {
  var url = $(this).attr('action') + '/preview';
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
jQuery.fn.applyRoles = function() {
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

jQuery.fn.surrounds = function(position) {
  me = $(this);
  meoff = me.offset();
  return(
      meoff.top < position.top && meoff.left < position.left &&
      meoff.top + me.height() > position.top &&
      meoff.left + me.width() > position.left
  );
}

jQuery.fn.beBusy = function(message) {
  var e = $(this);
  e.appendDom([
    { tagName: 'div', class: 'busy', childNodes: [
      { tagName: 'span', class: 'message', innerHTML: 'Loading' },
      { tagName: 'img', class: 'status', src: '/images/toolbox/pentagon.gif' }
    ] },
  ]);

  if (message)
    $('span.message', e).text(message);
    
    return e.fadeIn(230);
}
jQuery.fn.unBusy = function() {
  return $('div.busy', this).fadeOut(230).remove();
}


ChiliBook.recipeFolder = 'javascripts/syntax/'

$.ajaxSetup({
  dataType: 'script',
  beforeSend: function(request) {
    request.setRequestHeader("Tirade-Page", $('div.page').resourceId() )
  }
});

jQuery.metadata.setType( 'elem', 'script' );

$(function() {
  $('div.admin > a').livequery(function() { $(this).useToolbox(); });
  $('a.login').livequery(function() { $(this).useToolbox(); });
  $('a.with_toolbox').livequery(function() { $(this).useToolbox(); });
  $('a.dashboard').livequery('click', function(event) { 
    event.preventDefault();
    Toolbox.findOrCreate();
    Toolbox.last().refresh();
  });

  $('code.html').livequery(function() { $(this).chili() });
  $('code.liquid').livequery(function() { $(this).chili() });


  /* Resourceful Links in Toolbox */
  $('div#toolbox > div.body > div.content > div.frame a.show').livequery(function() { $(this).uiIcon('circle-triangle-e').useToolbox(); });
  $('div#toolbox > div.body > div.content > div.frame a.index').livequery(function() { $(this).uiIcon('circle-triangle-e').useToolbox(); });
  $('div#toolbox > div.body > div.content > div.frame a.new').livequery(function() { $(this).uiIcon('plus').useToolbox(); });
  $('div#toolbox > div.body > div.content > div.frame a.edit').livequery(function() { $(this).uiIcon('pencil').useToolbox(); });
  $('div#toolbox > div.body > div.content > div.frame a.destroy').livequery(function() { $(this).uiIcon('trash').useToolbox(); });
  $('div#toolbox_sidebar a.show').livequery(function() { $(this).uiIcon('circle-triangle-e').useToolbox(); });
  $('div#toolbox > div.body > div.content ul.tree.tree_root').livequery(function() { 
    $('div.node:not(:has(span.handle)):not(.page)', this).livequery( function() {
      $(this).append( $('<span>drag</span>').addClass('handle'))
    });
    $(this).mirrorsLayout(); 
    $(this).editLayout(); 
  });

  /* 
   * Toolbox Drag+Drop
   */
  $('ul.list.records > li, dl > di > dd.record').livequery(function() {
    $(this)
    .addClass('ui-widget-content ui-corner-all')
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

  $('ul.list, dl.list').livequery(function() { $(this).listOfItems() });

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
    $.ui.button({icon: 'circle-close', text: 'remove', class: 'association remove'})
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
  $('form.edit_part, form.edit_rendering').livequery(function() { $(this).preview(); });
  $('form.edit.content').livequery(function() { $(this).preview(); });
  $('form.edit_page').livequery(function() { $(this).preview(); });
  $('body').applyRoles();


  /* TODO: move to acts_as_custom_configurable */
  $('form ul.define_options').livequery(function() {
    var list = $(this);
    $.ui.button({icon: 'circle-plus', text: 'remove', class: 'add option'})
      .click(function() {
        list.find('li:last').clone().removeClass('dummy').appendTo(list);
        return false;
      })
      .prependTo(list);
  });
  $('form ul.define_options li:not(.dummy)').livequery(function() {
    var item = $(this);
    $.ui.button({icon: 'circle-close', text: 'remove', class: 'association remove'})
      .click(function() { item.remove(); return false; })
      .prependTo(item);
  });


  /* empty grid */
  $('body.role_admin div.page div.grid:not(:has(div.grid, div.rendering))').livequery(function() {
    $(this).addClass('empty').append('<div class="warning">Empty Grid. Open Toolbox, click on + to add Renderings</div>');
  });

  // mark hovered divs as hovered. we can get them later by $('div.hovered').last() for positioniing the toolbox
  $('div.rendering > div.admin, div.grid > div.admin').livequery(function() {
    $(this).hover(
      function() { 
        $(this).parent().addClass('hover') 
      }, 
      function() { 
        $('div.page .hover').removeClass('hover'); 
      }
    );
  });


});
