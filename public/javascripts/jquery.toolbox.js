
var Toolbox = {
  findOrCreate: function() {
    if ( this.element().length == 0 ) {
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
            ]}
          ]},
          { tagName: 'div', class: 'foot', childNodes: [
            { tagName: 'span', class: 'content status' }
          ]},
        ]}
      ]);

      this.element()
        .draggable( { handle: 'div.head' } )
        .resizable( {
          minWidth: 300, minHeight: 400,
          handles: 'e,se,s',
          resize : function(e,ui) {
            Toolbox.setSizes();
          },
        })
        .find('> div.body')
          .serialScroll({
            target: 'div.content',
            step: 1, cycle: false,
            lazy: true,
            items: 'div.content > div.frame',
            prev: 'a.prev', next: 'a.next',
            axis: 'xy',
            duration: 500
          })
        .end()
        .find(' > div.head > span.buttons')
          .find('> img.close').click(function() { Toolbox.close() }).end()
          .find('> img.min').click(function() { Toolbox.minimize() }).end()
          .find('> img.max').click(function() { Toolbox.maximize() }).end()
        .end()
        .show();
      $('div#toolbox a.back').livequery(function() { 
        $(this).click(function(ev) { 
          Toolbox.pop() 
          // TODO download dashboard if not already loaded
        })
      });
    };
    this.setSizes();
    return this.element();
  },
  setSizes: function() {
    $('div#toolbox div.body').height(
      $('div#toolbox').height() - $('div#toolbox div.head').height() - $('div#toolbox div.foot').height()
    );
    $('div#toolbox > div.body > div.content > div.frame').height( $('div#toolbox > div.body'));
    // $('div#toolbox > div.body').scrollTo('div.frame:last',{axis:'x'});
  },
  push: function(content,options) {
    var options = jQuery.extend({
      href:       '/dashboard',
      title:      '[No Title]'
    }, options);
    this.scroller().find('> div.content')
      .appendDom([
        {tagName: 'div', class: 'frame', href: options.href, innerHTML: content }
      ]);
    if (this.last().find('> ul.linkbar > li > a.back').length == 0) {
      this.last().find('> ul.linkbar').appendDom([this.newBackButton()])
    }
    this.next();
    this.setTitle(options.title);
  },
  newBackButton: function(title) {
    return(
      { tagName: 'li', childNodes: [
        { tagName: 'a', class: 'back', href: '#', innerHTML: 'back' }
      ]}
    );
  },
  pop: function() {
    this.prev();
    setTimeout( function() {
      Toolbox.last().remove();
    }, 500);
  },
  updateFrameByHref: function(href,content,options) {
    var options = jQuery.extend({
      title:      '[No Title]'
    }, options);
    this.element()
      .find('> div.body > div.content > div.frame[@href=href]')
        .html(content);
    this.setTitle(options.title);
  },
  popAndRefreshWith: function(content,options) {
    var options = jQuery.extend({
      title:      '[No Title]'
    }, options);
    this.scoller().find('> div.content > div.frame:last').prev().html(content);
    this.pop();
    this.setTitle(options.title);
  },
  updateLastFrame: function(content,options) {
    var options = jQuery.extend({
      title:      '[No Title]'
    }, options);
    this.last().html(content);
    this.setTitle(options.title);
  },
  setTitle: function(title) {
    return this.element().find('> div.head span.title').html(title);
  },
  setStatus: function(status) {
    return this.element().find('> div.foot span.status').html(status);
  },
  scroller: function() {
    return $('div#toolbox > div.body');
  },
  last: function() {
    return this.scroller().find('> div.content > div.frame:last');
  },
  element: function() {
    return $('div#toolbox');
  },
  next: function() {
    return this.scroller().trigger('next');
  },
  prev: function() {
    return this.scroller().trigger('prev');
  },
  close: function() {
    this.element().remove();
  }


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
    $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      dataType: 'script'
    });
  });
};
