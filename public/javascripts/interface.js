/*
 * Builds up the interface for tirade, needs jquery and more than one jquery plugin
 */

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
  }
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

  $('div#toolbox > div.body > div.content > div.frame a[href!=#]:not([class=back])').livequery(function() { $(this).useToolbox(); })
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
});
