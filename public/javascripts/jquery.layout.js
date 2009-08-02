/*
 * Stuff that has to do with Grids, Pages and Layout editing
 *
 * */

Rendering = {
  create: function(attributes) {
    $.ajax({
      url: Routing.renderings_url({format: 'js'}),
      data: $.toJSON({rendering: attributes}),
      contentType: 'application/json; charset=utf-8',
      type: 'POST'
    });
  },
  createButton: function(attributes) {
    return $.ui.button({
      icon: 'circle-plus', text: 'create rendering', 
      class: 'create rendering'
    })
    .click(function() {
      Toolbox.open();
      Rendering.create(attributes)
    })
  },
  update: function(rendering, attributes) {
    rendering = $(rendering).closest('.rendering');
    $.ajax({
      url: Routing.rendering_url({
        id: rendering.resourceId(), 
        format: 'js'
      }),
      data: $.toJSON({rendering: attributes}),
      contentType: 'application/json; charset=utf-8',
      type: 'PUT'
    });
  }
};

Grid = {
  sortRenderings: function(grid) {
    $.ajax({
      data: grid.sortable("serialize", {attribute: 'rel'}),
      url: Routing.order_renderings_grid_url({id: grid.resourceId()}),
      type: 'POST'
    });
  },
  sortRenderingsButton: function(grid) {
    return $.ui.button({
      icon: 'shuffle', text: 'sort Renderings', 
      class: 'sort grid renderings'
      })
      .toggle(
        function() {
          $(this).addClass('ui-state-active');
          grid.sortable('destroy').sortable({
            items: '> *.rendering',
            connectWith: ['div.page div.grid.leaf'],
            tolerance: 'pointer',
            containment: 'body',
            appendTo: 'body',
            placeholder: 'placeholder',
            //cursorAt: { top: 2, left: 2 },
            opacity: 0.5,
            activate: function(e, ui) { 
              grid.addClass('active-sortable'); 
            },
            deactivate: function(e, ui) {
              grid.removeClass('active-sortable'); 
            }
          });
        },
        function() {
          Grid.sortRenderings(grid);
          grid.sortable('destroy');
          $(this).removeClass('ui-state-active');
        }
      );
  },
  sortChildren: function(grid) {
    $.ajax({
      data: grid.sortable("serialize", {attribute: 'rel'}),
      url: Routing.order_children_grid_url({id: grid.resourceId()}),
      type: 'POST'
    });
  },
  sortChildrenButton: function(grid) {
    return $.ui.button({
      icon: 'shuffle', text: 'sort Children', 
      class: 'sort grid grids rendering'
      })
      .toggle(
        function() {
          $(this).addClass('ui-state-active');
          grid.sortable('destroy').sortable({
            items: '> .col',
            connectWith: ['div.page div.grid:not(.leaf)'],
            tolerance: 'pointer',
            containment: 'body',
            appendTo: 'body',
            placeholder: 'placeholder',
            //cursorAt: { top: 2, left: 2 },
            opacity: 0.5,
            activate: function(e, ui) { 
              grid.addClass('active-sortable'); 
            },
            deactivate: function(e, ui) {
              grid.removeClass('active-sortable'); 
            }
          });
        },
        function() {
          Grid.sortChildren(grid);
          grid.sortable('destroy');
          $(this).removeClass('ui-state-active');
        }
      );
  }
};

function context_page_id() {
  alert("you shall now use $.tirade.currentPageId()");
  return $('body div.page').resourceId();
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

  /*
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
  */

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

  if (!$.tirade) $.tirade = {};

  $.extend($.tirade, {
    currentPageId: function() {
      return $('body div.page').resourceId();
    }
  });


  $('div.page').livequery(function() {
    $(this).focusable({parent: null, children: '>div.grid'});
  });
  $('div.page div.grid').livequery(function() {
    $(this).focusable({
      parent: 'div.grid, div.page', 
      children: '> * > div.grid,>div.grid', 
      left_children: '>div.rendering',
      buttons: function() {
        var grid = $(this);
        buttons = [];
        if (grid.find('>.col').length > 1) {
          buttons.push( Grid.sortChildrenButton(grid) );
        }
        if (grid.is('.leaf')) {
          if (grid.find('>div.rendering').length > 1) {
            buttons.push( Grid.sortRenderingsButton(grid) );
          }
          buttons.push( Rendering.createButton({
            grid_id: grid.resourceId(),
            page_id: $.tirade.currentPageId()
          }));
        }
        return buttons;
      }
    })
  });
  $('div.page div.grid div.rendering').livequery(function() {
    $(this).focusable({
      parent: 'div.grid', 
      children: null,
      visit: function() {
        var $rendering = $(this);
        if ($rendering.is('.without_content')) {
          $rendering.droppable({
            accept: 'li.record:not(.part)',
            activeClass: 'active-droppable',
            hoverClass: 'drop-hover',
            greedy: true,
            tolerance: 'pointer',
            drop: function(e,ui) { 
              var content = ui.draggable.typeAndId();
              Rendering.update($rendering, {
                content_type: content.type,
                content_id: content.id
              });
            }
          });
        }
        if ($rendering.is('.without_part')) {
          $rendering.droppable({
            accept: 'li.part',
            activeClass: 'active-droppable',
            hoverClass: 'drop-hover',
            greedy: true,
            tolerance: 'pointer',
            drop: function(e,ui) { 
              var part = ui.draggable.typeAndId();
              Rendering.update($rendering, {
                part_id: part.id
              });
            }
          });
        }
      },
      leave: function() {
        var $rendering = $(this);
        $rendering.droppable('destroy');
      }
    });
  });

  $('div.page div.warning').livequery(function() {
    $(this)
      .addClass('ui-state-highlight')
      .addClass('ui-corner-all')
  });
});
