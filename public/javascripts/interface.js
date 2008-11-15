/*
 * Builds up the interface for tirade, needs jquery and more than one jquery plugin
 */


// returns just the number (23 of image_23)
jQuery.fn.resourceId = function() {
  if (m = $(this).attr('id').match(/(\d+)$/)) {
    return(m[1]);
  } else if (
    (first_href = $(this).children('a:first[@href!=#]').attr('href')) &&
    (m = first_href.match(/(\d+)$/))) {
    return(m[1]);
  } else if (
    (action = $(this).attr('action')) && 
    (action.match(/(\d+)\D*$/))) {
    return(m[1]);
  } else if ( m = $(this)[0].className.match(/_(\d+)/)) {
    return(m[1])
  }
}


// Returns image_23
jQuery.fn.resourceIdentifier = function() {
  if ( m = $(this)[0].className.match(/([a-z_]+_\d+)/)) {
    return(m[1])
  }
}

// Returns { type: 'Image', id: 23 }
jQuery.fn.typeAndId = function() {
  if (match = $(this)[0].className.match(/(.+)_(\d+)/)) {
    return({
      type: $.string(match[1]).gsub(/_/,'-').capitalize().camelize().str,
      id: match[2]
    });
  }
};

// Auto preview
jQuery.fn.preview = function() {
  var url = $(this).attr('action') + '/preview';
  var form = $(this);
  var fetchPreview = function(data) {
    $.ajax({
      url: url, 
      type: 'POST',
      data: data || form.formSerialize(),
      dataType: 'script'
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

ChiliBook.recipeFolder = 'javascripts/syntax/'

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

  $('div#toolbox > div.body > div.content > div.frame a[href!=#]:not([class=back])').livequery(function() { $(this).useToolbox(); });
  $('div#toolbox > div.sidebar a[href!=#]').livequery(function() { $(this).useToolbox(); });
  $('body.role_admin div.page div.rendering').livequery(function(i) {
    $(this).appendDom([
      { tagName: 'div', class: 'admin', id: 'admin_' + $(this).attr('id'), childNodes: [
        { tagName: 'a', href: rendering_url({id: $(this).resourceId()}), class: 'edit rendering', innerHTML: 'edit' },
        { tagName: 'span', class: 'handle', innerHTML: 'drag' }
        ] }
    ]);
  });
  $('div#toolbox ul.list > li').livequery(function() {
    $(this).draggable({ 
      helper: 'clone', 
      zIndex: 50, 
      appendTo: 'body'
    });
  });
  $('div#toolbox dl di dd.record').livequery(function() {
    $(this).draggable({ 
      helper: 'clone', 
      zIndex: 50, 
      appendTo: 'body',
      scroll: true
    });
  });
  // Clipboard
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
      drop: function(e,ui) {
        $.ajax({
          url: clipboard_url(),
          data: {id: $(ui.draggable).resourceIdentifier()},
          type: 'POST',
          dataType: 'script'
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
        type: 'DELETE',
        dataType: 'script'
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
      list.find('li:last').clone().appendTo(list);
      return false;
    });
  });
  $('form ul.define_options li').livequery(function() {
    var item = $(this);
    $('<img src="/images/icons/small/x.gif" class="remove option" />').prependTo(item);
    item.find('img.remove').click(function() {
      item.remove();
      return false;
    });
  });

  $('div.grid').sortable("destroy").sortable({
    connectWith: ['div.grid'],
    //containment: 'div.page',
    appendTo: 'div.page',
    distance: 5,
    dropOnEmpty: false,
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
      $.ajax({
        data: grid.sortable("serialize"),
        url: order_renderings_grid_url({id: grid.resourceId()}),
        type: 'POST', dataType: 'script'
      });
    }
  });
});
