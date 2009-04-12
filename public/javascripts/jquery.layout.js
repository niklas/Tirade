/*
 * Stuff that has to do with Grids, Pages and Layout editing
 *
 * */

$(function() {
  jQuery.fn.mirrorsLayout = function() {
    $('*.grid', this).livequery(function() {
      $(this).hover(
        function() {
          if ( id = $(this).resourceId() ) {
            $('div.page div.grid.grid_' + id).addClass('hover');
          }
        }, 
        function() {
          $('div.page div.grid').removeClass('hover');
        }
      );
    });

    // Mirror hovered Renderings
    $('*.rendering', this).livequery(function() {
      $(this).hover(
        function() {
          if ( id = $(this).resourceId() ) {
            $('div.page div.rendering#rendering_' + id).addClass('hover');
          }
        }, 
        function() {
          $('div.page div.rendering').removeClass('hover');
        }
      );
    });
  };

  jQuery.fn.editLayout = function() {
    var tree = $(this);

    // Mirror hovered Grids

    // Grid with Renderings
    function order_renderings_for_grid(event, ui) {
      var list = ui.element;
      var grid = list.parents('.grid:first');
      console.debug("Saving Order of Renderings for", grid[0], 'list:' + list[0]);
      console.debug(list.sortable("serialize", {attribute: 'rel'}));
      if (grid.find('.' + ui.item.resourceIdentifier()).length) {
        $.ajax({
          data: list.sortable("serialize", {attribute: 'rel'}) + pageContextForRequest(),
          url: order_renderings_grid_url({id: grid.resourceId()}),
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
          data: list.sortable("serialize", {attribute: 'rel'}) + pageContextForRequest(),
          url: order_children_grid_url({id: grid.resourceId()}),
          type: 'POST'
        });
      }
      event.preventDefault();event.stopPropagation();
    };
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
    $(this).prepend(
      $('<div />').addClass('admin').attr('id', 'admin_' + $(this).attr('id'))
        .append( $('<a>edit</a>').addClass('edit rendering').attr('href', rendering_url({id: $(this).resourceId()})) )
        .append( $('<span>drag</span>').addClass('handle'))
    )
  });

  $.fn.toggleEditPage = function() {
    $(this).toggle( 
      function() {
        console.debug('editing page');
        $('body div.page div.rendering').find(' > div.admin, > div.admin span.handle').show();
        $('body div.page').editLayout();
      },
      function() {
        console.debug('stopped editing page');
        $('body div.page *').sortable('destroy').droppable('destroy');
        $('body div.page div.rendering').find(' > div.admin, > div.admin span.handle').hide().css('display','');
      } 
    );
  };

  $.fn.oldDragAndDrop = function() {
    // Grid leafs
    $('div.grid:not(:has(> div.grid))').livequery(function() {
      $(this).sortable({
        connectWith: ['div.grid:not(:has(> div.grid))'],
        //containment: 'div.page',
        appendTo: 'div.page',
        distance: 5,
        dropOnEmpty: true,
        placeholder: 'placeholder',
        forcePlaceHolderSize: true,
        items: '> div.rendering',
        handle: 'span.handle',
        tolerance: 'intersect',
        scroll: true,
        cursor: 'move',
        zIndex: 1,
        change: function(e,ui) {
          ui.item.width(ui.element.width());
        },
        stop: function(e,ui) {
          $('div.rendering').width('');
          var grid = ui.element.parents('.grid:first');
          $.ajax({
            data: grid.sortable("serialize"),
            url: order_renderings_grid_url({id: grid.resourceId()}),
            type: 'POST'
          });
        }
      })
      .droppable({
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
                url: rendering_url({id: droppee.id}),
                data: context,
                type: 'PUT'
              });
              break;
            case 'Part': /* Part from Toolbox creates Rendering without a Content */
              $.ajax({
                url: renderings_url(),
                data: context + '&rendering[part_id]=' + droppee.id,
                type: 'POST'
              });
              break;
            default: /* dropping anything else will create a Rendering with this assigned as content */
              $.ajax({
                url: renderings_url(),
                data: context + 
                      '&rendering[content_id]=' + droppee.id +
                      '&rendering[content_type]=' + droppee.type,
                type: 'POST'
              });
          }
        }
      });
    });

    $('div.rendering.without_part').livequery(function() {
      $(this).droppable({
        accept: 'li.part',
        activeClass: 'active-droppable',
        hoverClass: 'drop-invite',
        greedy: true,
        tolerance: 'pointer',
        drop: function(e,ui) {
          var droppee = ui.draggable.typeAndId();
          $.ajax({
            url: rendering_url({id: ui.element.resourceId()}),
            data: 'rendering[part_id]=' + droppee.id,
            type: 'PUT'
          });
        }
      });
    });
    $('div.rendering.without_content').livequery(function() {
      $(this).droppable({
        accept: 'li:not(.part)',
        activeClass: 'active-droppable',
        hoverClass: 'drop-invite',
        greedy: true,
        tolerance: 'pointer',
        drop: function(e,ui) {
          var droppee = ui.draggable.typeAndId();
          $.ajax({
            url: rendering_url({id: ui.element.resourceId()}),
            data: 'rendering[content_id]=' + droppee.id +
                  '&rendering[content_type]=' + droppee.type,
            type: 'PUT'
          });
        }
      });
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
            data: grid.sortable("serialize") + pageContextForRequest(),
            url: order_children_grid_url({id: grid.resourceId()}),
            type: 'POST'
          });
        }
      })
    });
  }
});
