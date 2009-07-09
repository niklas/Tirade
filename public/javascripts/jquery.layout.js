/*
 * Stuff that has to do with Grids, Pages and Layout editing
 *
 * */

function context_page_id() {
  return $('body div.page').resourceId();
}

function order_renderings_for_grid(event, ui) {
  var list = ui.element;
  if (list.is('.grid')) {
    var grid = list;
  } else {
    var grid = list.parents('.grid:first');
  }
  console.debug("Saving Order of Renderings for", grid[0], 'list:' + list[0]);
  console.debug(list.sortable("serialize", {attribute: 'rel'}));
  if (list.find(ui.item).length) { // only if the dropped item is in our list know, we have only to track sorting and adding here
    $.ajax({
      data: list.sortable("serialize", {attribute: 'rel'}),
      url: Routing.order_renderings_grid_url({id: grid.resourceId()}),
      type: 'POST'
    });
  }
  event.preventDefault();event.stopPropagation();
};
function order_children_for_grid(event, ui) {
  var list = ui.placeholder.parent();
  var grid = list.parents('.grid:first');
  console.debug("Sorting Order of children for", grid[0], 'list:' + $(list)[0]);
  console.debug(list.sortable("serialize", {attribute: 'rel'}));
  if (grid.find('.' + ui.item.resourceIdentifier()).length) {
    $.ajax({
      data: list.sortable("serialize", {attribute: 'rel'}),
      url: Routing.order_children_grid_url({id: grid.resourceId()}),
      type: 'POST'
    });
  }
  event.preventDefault();event.stopPropagation();
};

function create_new_rendering_for_grid(grid) {
  context = "rendering[grid_id]=" + grid.resourceId();
  context += "&rendering[page_id]=" + context_page_id()
  $.ajax({ data: context, url: Routing.renderings_url(), type: 'POST' });
};

function update_content_of_rendering(content,rendering) {
  var what = content.typeAndId();
  data = 'rendering[content_id]=' + what.id;
  data += '&rendering[content_type]=' + what.type;
  $.ajax({ url: Routing.rendering_url({id: rendering.resourceId()}), data: data, type: 'PUT' });
}

function update_part_of_rendering(part, rendering) {
  data = 'rendering[part_id]=' + part.resourceId();
  $.ajax({ url: Routing.rendering_url({id: rendering.resourceId()}), data: data, type: 'PUT' });
}

$(function() {
  jQuery.fn.mirrorsLayout = function() {
    $('*.grid', this).livequery(function() {
      $(this).hover(
        function() { if ( id = $(this).resourceId() ) $('div.page div.grid.grid_' + id).addClass('hover'); }, 
        function() { $('div.page div.grid').removeClass('hover'); }
      );
    });

    // Mirror hovered Renderings
    $('*.rendering', this).livequery(function() {
      $(this).hover(
        function() { if ( id = $(this).resourceId() ) $('div.page div.rendering#rendering_' + id).addClass('hover'); }, 
        function() { $('div.page div.rendering').removeClass('hover'); }
      );
    });
  };

  jQuery.fn.editLayout = function() {
    var tree = $(this);

    // Mirror hovered Grids

    // Grid with Renderings
    $('*.grid > *:has(> li.rendering, > div.rendering)', this).livequery(function() {
      $(this).sortable({
        items: '> *.rendering',
        connectWith: ['*.grid > :not(:has(> *.grid))', '*.grid > *.empty'],
        tolerance: 'pointer',
        containment: tree,
        handle: 'span.handle',
        placeholder: 'placeholder',
        forcePlaceHolderSize: true,
        cursorAt: { top: 2, left: 2 },
        opacity: 0.5,
        update: function(e,ui) {
          if (!ui.sender) order_renderings_for_grid(e,ui);
        },
        receive: function(e,ui) {
          if (ui.sender) order_renderings_for_grid(e,ui);
        },
        remove: function(e,ui) {
          $('*.' + ui.item.resourceIdentifier(), $('div.page')).remove();
        },
        activate: function(e, ui) { ui.element.addClass('active-sortable'); },
        deactivate: function(e, ui) { ui.element.removeClass('active-sortable'); }
      })/*.droppable({
        accept: 'li.rendering',
        tolerance: 'pointer',
        activeClass: 'active-droppable',
        hoverClass: 'drop-hover',
        greedy: true,
        drop: order_renderings_for_grid
        })*/;
    });
      // Sort Children of Grid
    $('*.grid > *:has(> li.grid, > div.grid)', this).livequery(function() {
      $(this).sortable({
        items: '> *.grid',
        connectWith: ['*.grid > :not(:has(> *.rendering))', '*.grid > *.empty'],
        tolerance: 'pointer',
        containment: tree,
        handle: 'span.handle',
        placeholder: 'placeholder',
        forcePlaceHolderSize: true,
        cursorAt: { top: 2, left: 2 },
        opacity: 0.5,
        update: function(e,ui) {
          if (!ui.sender) order_children_for_grid(e,ui);
        },
        receive: function(e,ui) {
          if (ui.sender) order_children_for_grid(e,ui);
        },
        remove: function(e, ui) {
          console.debug("Removed element from", this)
        },
        activate: function(e, ui) { ui.element.addClass('active-sortable'); },
        deactivate: function(e, ui) { ui.element.removeClass('active-sortable'); }
      })/*.droppable({
        accept: 'li.grid',
        tolerance: 'pointer',
        activeClass: 'active-droppable',
        hoverClass: 'drop-hover',
        greedy: true,
        drop: order_children_for_grid
        })*/;
    });

    // Move Renderings/Grids to empty Grid
    $('li.grid:not(:has(> ul))', this).livequery(function() {
      $('<ul class="empty tree" />').appendTo($(this));
    })

    $('*.grid > *.empty', this).livequery(function() {
      $(this).
      sortable({
        items: '> .rendering, > .grid',
        connectWith: ['*.grid > *'],
        tolerance: 'pointer',
        containment: tree,
        placeholder: 'placeholder',
        forcePlaceHolderSize: true,
        update: function(event, ui) {
          var droppee = ui.item.typeAndId();
          console.debug("detected sorting Drop of", droppee.type, "on empty");
          switch(droppee.type) {
            case 'Rendering':
              order_renderings_for_grid(event, ui);
              break;
            case 'Grid':
              order_children_for_grid(event,ui);
              break;
            default:
              console.debug("Do not know how to handle", droppee.type);
          }
          event.preventDefault();event.stopPropagation();
        }
        })/*.
      droppable({
        accept: 'li.grid, li.rendering',
        tolerance: 'pointer',
        activeClass: 'active-droppable',
        hoverClass: 'drop-hover',
        greedy: true,
        drop: function(e, ui) {
          var droppee = ui.draggable.typeAndId();
          console.debug("dropped", droppee.type, "on empty");
          switch(droppee.type) {
            case 'Rendering':
              order_renderings_for_grid(e, ui);
              break;
            case 'Grid':
              order_children_for_grid(e,ui);
              break;
            default:
              console.debug("Do not know how to handle", droppee.type);
          }
        }
        })*/;
    });
  };


  // Admin Bars on Renderings
  $('body.role_admin div.page div.rendering').livequery(function(i) {
    var rendering = $(this);
    rendering.prepend(
      $('<div />').addClass('admin').attr('id', 'admin_' + rendering.resourceIdentifier())
        .append( $('<a>edit</a>').addClass('edit rendering').attr('href', Routing.rendering_url({id: $(this).resourceId()})) )
        .append( $('<span>drag</span>').addClass('handle'))
    )
  });

  // Admin Bars on Grids
  $('body.role_admin div.page div.grid div.grid').livequery(function(i) {
    var grid = $(this);
    div = $('<div />').addClass('admin').attr('id', 'admin_' + grid.resourceIdentifier());
    if (grid.is('.leaf')) {
      div.append( $('<a>add rendering</a>')
           .addClass('create rendering without_toolbox')
           .click( function(e) { create_new_rendering_for_grid(grid); e.preventDefault(); e.stopPropagation(); return false; } )
      )
    }
    grid.prepend(
        div.append( $('<span>drag</span>').addClass('handle'))
    )
  });

  $.fn.toggleEditPage = function() {
    $(this).toggle( 
      function() {
        $('body div.page div.rendering, body div.page div.grid').livequery( function() {
          $(this).find(' > div.admin').show();
        });
        $('body div.page div.grid.leaf').livequery(function() {
          $(this).sortable({
            connectWith: ['body div.page div.grid.leaf'],
            //containment: 'div.page',
            appendTo: 'div.page',
            distance: 5,
            dropOnEmpty: true,
            placeholder: 'placeholder',
            opacity: 0.5,
            items: '> div.rendering',
            handle: 'span.handle',
            tolerance: 'pointer',
            scroll: true,
            cursor: 'move',
            zIndex: 1,
            change: function(e,ui) {
              ui.item.width(ui.element.width());
            },
            update: function(e,ui) {
              $('div.rendering').width('');
              order_renderings_for_grid(e,ui);
            },
            activate: function(e, ui) { ui.element.addClass('active-sortable'); },
            deactivate: function(e, ui) { ui.element.removeClass('active-sortable'); }
          })
        });
        $('body div.page div.rendering.without_content').livequery(function() {
          $(this).droppable({
            accept: 'li:not(.part)',
            activeClass: 'active-droppable',
            hoverClass: 'drop-hover',
            greedy: true,
            tolerance: 'pointer',
            drop: function(e,ui) { update_content_of_rendering(ui.draggable, ui.element); }
          });
        });
        $('body div.page div.rendering.without_part').livequery(function() {
          $(this).droppable({
            accept: 'li.part',
            activeClass: 'active-droppable',
            hoverClass: 'drop-hover',
            greedy: true,
            tolerance: 'pointer',
            drop: function(e,ui) { update_part_of_rendering(ui.draggable, ui.element) }
          });
        });

      },
      function() {
        $('body div.page div.grid.leaf').expire();
        $('body div.page div.rendering.without_part').expire();
        $('body div.page div.rendering.without_content').expire();
        $('body div.page *').sortable('destroy').droppable('destroy');
        $('body div.page div.rendering, body div.page div.grid').expire();
        $('body div.page div.rendering > div.admin').hide().css('display','');
        $('body div.page div.grid > div.admin').hide().css('display','');
      } 
    );
  };

  $.fn.oldDragAndDrop = function() {
    // Grid leafs
          $(this).droppable({
            accept: 'li',
            activeClass: 'active-droppable',
            hoverClass: 'drop-hover',
            greedy: true,
            tolerance: 'pointer',
            drop: function(e,ui) {
              var droppee = ui.draggable.typeAndId();
              context = "rendering[grid_id]=" + ui.element.resourceId();
              context += "&rendering[page_id]=" + $('body > div.page').resourceId();
              switch(droppee.type) {
                case 'Rendering': /* drop renderings (hints) from toolbox, updates its #grid */
                  $.ajax({
                    url: Routing.rendering_url({id: droppee.id}),
                    data: context,
                    type: 'PUT'
                  });
                  break;
                case 'Part': /* Part from Toolbox creates Rendering without a Content */
                  $.ajax({
                    url: Routing.renderings_url(),
                    data: context + '&rendering[part_id]=' + droppee.id,
                    type: 'POST'
                  });
                  break;
                default: /* dropping anything else will create a Rendering with this assigned as content */
                  $.ajax({
                    url: Routing.renderings_url(),
                    data: context + 
                          '&rendering[content_id]=' + droppee.id +
                          '&rendering[content_type]=' + droppee.type,
                    type: 'POST'
                  });
              }
            }
          });


    /* lets sort all vertical aligned Grids, if there is more than one child */
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
          $.ajax({
            data: grid.sortable("serialize"),
            url: Routing.order_children_grid_url({id: grid.resourceId()}),
            type: 'POST'
          });
        }
      })
    });
  }
});
