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

// Apply roles classes from cookie (for body etc.)
jQuery.fn.applyRoles = function() {
  var e = $(this);
  $(e[0].className.split(/ /)).each(function(i,cls) {
    if (cls.match(/role_\S*/))
      e.removeClass(cls)
  });
  $($.cookie("roles").split(/&/)).each(function(i,role) {
    e.addClass('role_' + role);
  });
  e.addClass('cookie_roles');
  return(e);
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

  $('div#toolbox > div.body > div.content > div.frame a[href!=#]:not([class=back])').livequery(function() { $(this).useToolbox(); });
  $('div#toolbox > div.sidebar a[href!=#]').livequery(function() { $(this).useToolbox(); });
  $('body div.grid').livequery(function() {
    $(this).appendDom([
      { tagName: 'div', class: 'admin', id: 'admin_' + $(this).attr('id'), childNodes: [
        { tagName: 'a', href: edit_grid_url({id: $(this).resourceId()}), class: 'edit grid', innerHTML: 'edit' }
      ] }
    ])}
  );
  $('body.role_admin div.rendering').livequery(function(i) {
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
  // Clipboard
  $('div#toolbox div.sidebar ul.clipboard').livequery(function() {
    $(this).droppable({
      accept: 'li',
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
  $('body').applyRoles();
});
