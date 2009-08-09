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
    var $grid = $(this);
    $grid.focusable({
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
    });
    if ($grid.is('.without_renderings')) {
      $('<a />')
        .text('Focus')
        .href('#')
        .click( $grid.focus )
        .appendTo($grid);
    };
  });
  $('div.page div.grid div.rendering').livequery(function() {
    var $rendering = $(this);
    $rendering.focusable({
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
    if ($rendering.is('.without_content, .without_part')) {
      $('<a />')
        .text('Focus')
        .href('#')
        .click( $rendering.focus )
        .appendTo($rendering);
    };
  });

  $('div.page div.warning').livequery(function() {
    $(this)
      .addClass('ui-state-highlight')
      .addClass('ui-corner-all')
  });
});
