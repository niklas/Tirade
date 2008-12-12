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
    fetchPreview(form.find('input[@name=authenticity_token],input[@name=_method],input[@name=context_page_id]').serialize()); /* reset old state */
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

  minih = (e.height() > e.width() ? e.width() : e.height()) * 0.7;
  if (e.height() > e.width()) { /* "Bert" */
    $('img.status', e)
      .animate({
        top: (e.height() - minih) * 0.6, 
        left: (e.width() - minih) * 0.5, 
        height: minih,
        opacity: 1
      },800);
  } else { /* "Ernie" */
    $('img.status', e)
      .animate({
        top: (e.height() - minih) * 0.5, 
        left: e.width() - (minih * 1.1), 
        height: minih,
        opacity: 1
      },800);
  }
  
  if (message)
    $('span.message', e).text(message);
    
    return e.fadeIn(230);
}
jQuery.fn.unBusy = function() {
  return $('div.busy', this).fadeOut(230).remove();
}


ChiliBook.recipeFolder = 'javascripts/syntax/'

$.ajaxSetup({
  dataType: 'script'
});

function pageContextForRequest() {
  return "&context_page_id=" + $('body > div.page').resourceId()
}

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
  $('code.rhtml').livequery(function() { $(this).chili() });

  $('div#toolbox > div.body > div.content > div.frame a[href!=#]:not(.back)').livequery(function() { $(this).useToolbox(); });
  $('div#toolbox > div.sidebar a[href!=#]').livequery(function() { $(this).useToolbox(); });
  $('body.role_admin div.page div.rendering:not(.fake)').livequery(function(i) {
    $(this)
      .appendDom([
        { tagName: 'div', class: 'admin', id: 'admin_' + $(this).attr('id'), childNodes: [
          { tagName: 'a', href: rendering_url({id: $(this).resourceId()}), class: 'edit rendering', innerHTML: 'edit' },
          { tagName: 'span', class: 'handle', innerHTML: 'drag' }
          ] }
      ])
      .droppable({
        accept: 'li,dd',
        hoverClass: 'hover',
        activeClass: 'active-droppable',
        tolerance: 'pointer',
        drop: function(e,ui) {
          var droppee = ui.draggable.typeAndId();
          data = '';
          ui.element.beBusy("applying " + droppee.type);
          switch(droppee.type) {
            case 'Part': 
              data += 'rendering[part_id]=' + droppee.id;
              break;
            default:
              data += 'rendering[content_id]=' + droppee.id;
              data += '&rendering[content_type]=' + droppee.type;
          }
          data += pageContextForRequest();
          $.ajax({
            url: rendering_url({id: ui.element.resourceId()}),
            data: data, type: 'PUT'
          });
        }
      });
  });
  $('body.role_admin div.page div.grid div.rendering.fake').livequery(function(i) {
    $(this)
      .droppable({
        accept: 'li,dd',
        hoverClass: 'hover',
        activeClass: 'active-droppable',
        tolerance: 'pointer',
        drop: function(e,ui) {
          var droppee = ui.draggable.typeAndId();
          ui.element.beBusy("applying " + droppee.type);
          data = 'rendering[grid_id]=' + ui.element.parent().resourceId();
          data += '&rendering[page_id]=' + ui.element.parents('div.page').resourceId();
          switch(droppee.type) {
            case 'Part': 
              data += '&rendering[part_id]=' + droppee.id;
              break;
            default:
              data += '&rendering[content_id]=' + droppee.id;
              data += '&rendering[content_type]=' + droppee.type;
          }
          data += pageContextForRequest();
          $.ajax({
            url: renderings_url(),
            data: data, type: 'POST'
          });
        }
      });
  });
  $('div#toolbox ul.list > li,div#toolbox dl di dd.record').livequery(function() {
    $(this).draggable({ 
      helper: 'clone', 
      zIndex: 500, 
      appendTo: 'body',
      scroll: true,
      cursor: 'crosshair',
      cursorAt: {top: 0, left: 0},
      drag: function(e,ui) {
        if (Toolbox.surrounds(ui.absolutePosition)) {
          if ( !Toolbox.exclusive ) {
            Toolbox.otherDroppables().droppable("disable").removeClass('hover');
            Toolbox.exclusive = true;
          }
        } else {
          if ( Toolbox.exclusive ) {
            Toolbox.otherDroppables().droppable("enable");
            Toolbox.exclusive = false;
          }
        };
      }
    });
  });
  $('div#toolbox div.sidebar ul.clipboard').livequery(function() {
    var list = $(this);
    list.droppable({
      accept: function(draggable) { 
        return(
          draggable.is('li, dd.record') &&
          draggable.parent()[0] != list[0]
        );
      },
      hoverClass: 'hover',
      activeClass: 'active-droppable',
      greedy: true,
      tolerance: 'touch',
      drop: function(e,ui) {
        $.ajax({
          url: clipboard_url(),
          data: {id: $(ui.draggable).resourceIdentifier()},
          type: 'POST'
        });
      }
    });
  });
  $('div#toolbox div.sidebar ul.clipboard li').livequery(function() {
    var item = $(this);
    item.find('img.association').remove();
    item.appendDom([ { tagName: 'img', src: '/images/icons/small/x.gif', class: 'association remove' } ]);
    item.find('img.remove').click(function(event) { 
      item.remove(); 
      $.ajax({
        url: clipboard_url(),
        data: {id: item.resourceIdentifier()},
        type: 'DELETE'
      });
    });
  });
  $('form.edit_part, form.edit_rendering').livequery(function() {
    $(this).preview();
  });
  $('form.edit.content').livequery(function() {
    $(this).preview();
  });
  $('body').applyRoles();


  /* TODO: move to acts_as_custom_configurable */
  $('form ul.define_options').livequery(function() {
    var list = $(this);
    $('<img src="/images/icons/small/plus.gif" class="add option" />').prependTo(list);
    list.find('img.add').click(function() {
      list.find('li:last').clone().removeClass('dummy').appendTo(list);
      return false;
    });
  });
  $('form ul.define_options li:not(.dummy)').livequery(function() {
    var item = $(this);
    $('<img src="/images/icons/small/x.gif" class="remove option" />').prependTo(item);
    item.find('img.remove').click(function() {
      item.remove();
      return false;
    });
  });

  $('div.grid:not(:has(> div.grid))').livequery(function() {
    $(this).sortable("destroy").sortable({
      connectWith: ['div.grid:not(:has(> div.grid))'],
      //containment: 'div.page',
      appendTo: 'div.page',
      distance: 5,
      dropOnEmpty: true,
      placeholder: 'placeholder',
      forcePlaceHolderSize: true,
      items: '> div.rendering',
      handle: 'span.handle',
      tolerance: 'pointer',
      scroll: true,
      cursor: 'move',
      zIndex: 1,
      change: function(e,ui) {
        ui.item.width(ui.element.width());
      },
      stop: function(e,ui) {
        $('div.rendering').width('');
        grid = ui.item.parent();
        grid.find(' > div.rendering.fake').hide();
        $.ajax({
          data: grid.sortable("serialize"),
          url: order_renderings_grid_url({id: grid.resourceId()}),
          type: 'POST'
        });
      }
    })
    .find(' > div.rendering.fake').show().end()
    .droppable({
      accept: 'li.rendering',
      hoverClass: 'hover',
      activeClass: 'active-droppable',
      greedy: true,
      tolerance: 'pointer',
      drop: function(e,ui) {
        ui.element.find(' > div.rendering.fake').hide();
        $.ajax({
          url: rendering_url({id: ui.draggable.resourceId()}),
          data: "rendering[grid_id]=" + ui.element.resourceId() + pageContextForRequest(),
          type: 'PUT'
        });
      }
    });
  });


  /* empty grid */
  $('div.page div.grid:not(:has(> div.grid, > div.rendering))').livequery(function() {
    $(this).html('<div class="rendering fake">empty - drop something here</div>')
  });

  /* lets sort all vertical aligned grids, if there is more than one child */
  $('div.page div.grid:not(.horizontal):has(> div.grid + div.grid)').livequery(function() {
    $(this).find('> div.grid').append('<div class="admin"><span class="handle" /></div>').end()
    .sortable("destroy").sortable({
      handle: 'span.handle',
      axis: 'y',
      distance: 10,
      placeholder: 'placeholder',
      forcePlaceHolderSize: true,
      items: '> div.grid',
      tolerance: 'pointer',
      cursor: 'move',
      stop: function(e,ui) {
        grid = ui.item.parent();
        console.debug("Sorted Grids: ", grid.resourceId(), grid.sortable("serialize"));
        $.ajax({
          data: grid.sortable("serialize") + pageContextForRequest(),
          url: order_children_grid_url({id: grid.resourceId()}),
          type: 'POST'
        });
      }
    })
  });
  // mark hovered divs as hovered. we can get them later by $('div.hovered').last() for positioniing the toolbox
  $('div.rendering > div.admin, div.grid > div.admin').livequery(function() {
    $(this).hover(
      function() { 
        $('div.page .hover').removeClass('hover'); 
        $(this).parents('div.grid, div.rendering').addClass('hover') 
      }, 
      function() { $('div.page .hover').removeClass('hover'); }
    );
  });

  /* click grid mockups to browse */
  $('di.layout > dd > div.grid.preview').livequery(function() {
    $(this).click(function(e) {
      if ( id = $(e.target).resourceId() ) {
        $.get(grid_url({id: id}));
      } else if ( id = $(e.target).parent().resourceId() ) {
        $.get(grid_url({id: id}));
      }
    });
  });

});
