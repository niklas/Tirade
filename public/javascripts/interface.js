/*
 * Builds up the interface for tirade, needs jquery and more than one jquery plugin
 */

jQuery.fn.resourceId = function() {
  if (m = $(this).attr('id').match(/(\d+)$/)) {
    return(m[1]);
  } else if (m = $(this).children('a.rendering')[0].attr['href'].match(/(\d+)$/)) {
    return(m[1]);
  } else if (m = $(this).attr['action'].match(/(\d+)\D*$/)) {
    return(m[1]);
  }
}

$(function() {
  $('div.admin > a').livequery(function() { $(this).useToolbox(); });
  $('a.login').livequery(function() { $(this).useToolbox(); });
  $('a.with_toolbox').livequery(function() { $(this).useToolbox(); });

  $('div#toolbox > div.body > div.content > div.frame a[href!=#]:not([class=back])').livequery(function() { $(this).useToolbox(); })
  $('body div.grid').each(function(i) {
    $(this).appendDom([
      { tagName: 'div', class: 'admin', id: 'admin_' + $(this).attr('id'), childNodes: [
        { tagName: 'a', href: edit_grid_url({id: $(this).resourceId()}), class: 'edit grid', innerHTML: 'edit' }
      ] }
    ])}
  );
  $('body div.rendering').each(function(i) {
    $(this).appendDom([
      { tagName: 'div', class: 'admin', id: 'admin_' + $(this).attr('id'), childNodes: [
        { tagName: 'a', href: rendering_url({id: $(this).resourceId()}), class: 'edit rendering', innerHTML: 'edit' },
        { tagName: 'span', class: 'handle', innerHTML: 'drag' }
        ] }
    ]);
  });
  $('div#toolbox > div.body > div.content > div.frame > div.accordion').livequery(function() { 
    $(this).accordion({ header: 'h3.accordion_toggle', selectedClass: 'selected' });
  });
});
