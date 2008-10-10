
var Toolbox = {
  findOrCreate: function() {
    if ( $('div#toolbox').length == 0 ) {
      $('body').appendDom([
        { tagName: 'div', id: 'toolbox', childNodes: [
          { tagName: 'div', class: 'head', childNodes: [
            { tagName: 'span', class: 'content title', innerHTML: 'Toolbox Title is loooooooooooooong' },
            { tagName: 'span', class: 'buttons', childNodes: [
              { tagName: 'img', class: 'close', src: '/images/window/close.jpg' },
              { tagName: 'img', class: 'min',   src: '/images/window/min.jpg' },
              { tagName: 'img', class: 'max',   src: '/images/window/max.jpg' }
            ]}
          ]},
          { tagName: 'div', class: 'sidebar left', innerHTML: 'Sidebar foo foo' },
          { tagName: 'div', class: 'body', childNodes: [
            { tagName: 'div', class: 'content', id: 'toolbox_content', childNodes: [
              { tagName: 'div', class: 'frame', innerHTML: 'Frame 1 (only Frame - Dashboard)'},
              { tagName: 'div', class: 'frame', innerHTML: 'Frame 2 just kidding'}
            ]}
          ]},
          { tagName: 'div', class: 'foot', childNodes: [
            { tagName: 'span', class: 'content status', innerHTML: 'status' },
            { tagName: 'a', href: '#', class: 'prev', innerHTML: 'prev' },
            { tagName: 'a', href: '#', class: 'next', innerHTML: 'next' }
          ]},
        ]}
      ]);

      $('div#toolbox')
        .draggable( { handle: 'div.head' } )
        .resizable( {
          minWidth: 300, minHeight: 400,
          handles: 'e,se,s',
          resize : function(e,ui) {
            Toolbox.setSizes();
          },
          start: function(e,ui) {
            console.debug("starting to resize ", e);
          }
        })
        .find('div.body').serialScroll({
          target: 'div.content',
          step: 1, cycle: false,
          start: 0,
          lazy: true, force: true,
          items: 'div.frame',
          prev: 'a.prev', next: 'a.next',
          axis: 'xy'
          })
        .end()
        .show();
    };
    this.setSizes();
    return $('div#toolbox');
  },
  setSizes: function() {
    $('div#toolbox div.body').height(
      $('div#toolbox').height() - $('div#toolbox div.head').height() - $('div#toolbox div.foot').height()
    );
    $('div#toolbox div.body div.content div.frame').height( $('div#toolbox div.body'));
    $('div#toolbox div.body').scrollTo('div.frame:last',{axis:'x'});
  },
};

jQuery.fn.useToolbox = function(options) {
  var settings = jQuery.extend({

    onStart: function() {
    }
  }, options);
  $(this).hover(
    // mark hovered divs as hovered. we can get them later by $('div.hovered').last() for positioniing the toolbox
    function() {
      $(this).parents('div.grid, div.rendering').addClass('hovered');
    }, function() {
      $(this).parents('div.grid, div.rendering').removeClass('hovered');
    }
  );
  $(this).click(function(event) {
    Toolbox.findOrCreate();
    event.preventDefault();
    /*
    $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      dataType: 'script'
    });
    */
  });
};
