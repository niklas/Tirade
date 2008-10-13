
var Toolbox = {
  findOrCreate: function() {
    if ( this.element().length == 0 ) {
      $('body').appendDom([
        { tagName: 'div', id: 'toolbox', childNodes: [
          { tagName: 'div', class: 'head', childNodes: [
            { tagName: 'span', class: 'content title', innerHTML: 'Toolbox Title is loooooooooooooong' },
            { tagName: 'span', class: 'buttons', childNodes: [
              { tagName: 'img', class: 'close', src: '/images/icons/small/x.gif' },
              { tagName: 'img', class: 'max',   src: '/images/icons/small/grow.gif' },
              { tagName: 'img', class: 'min',   src: '/images/icons/small/pause.gif' }
            ]}
          ]},
          { tagName: 'div', class: 'sidebar left', innerHTML: 'Sidebar foo foo' },
          { tagName: 'div', class: 'body', childNodes: [
            { tagName: 'div', class: 'content', id: 'toolbox_content', childNodes: [
              Toolbox.newFrame('Hello!'),
            ]}
          ]},
          { tagName: 'div', class: 'foot', childNodes: [
            { tagName: 'span', class: 'content status' }
          ]},
        ]}
      ]);
      this.sidebarVisible = true;

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
      $('div#toolbox > div.body > div.content > div.frame:not(:first)').livequery(function() { 
        Toolbox.setTitle();
      });
      $('div#toolbox > div.body > div.content > div.frame form').livequery(function() { $(this).ajaxifyForm() });
      $('div#toolbox > div.body > div.content > div.frame > ul.linkbar').livequery(function() { 
        console.debug("New Linkbar!");
        Toolbox.setTitle();
        if ($(this).find('> li > a.back').length == 0) {
          $(this).appendDom([Toolbox.newBackButton()])
        }
      });
      $.timer(60 * 1000,function() {
        if (!Toolbox.minimized) {
          console.debug("Refreshing Dashboard");
          Toolbox.frameByHref('/dashboard').refresh();
        }
      });
    };
    this.setSizes();
    return this.element();
  },
  setSizes: function() {
    this.scroller().height( this.bodyHeight() );
    $('div#toolbox > div.body > div.content > div.frame').height( $('div#toolbox > div.body'));
    this.scroller().scrollTo('div.frame:last',{axis:'x'});
  },
  bodyHeight: function() {
    return $('div#toolbox').height() - this.decorationHeight()
  },
  decorationHeight: function() {
    return $('div#toolbox > div.head').height() + $('div#toolbox > div.foot').height()
  },
  push: function(content,options) {
    this.scroller().find('> div.content')
      .appendDom([ Toolbox.newFrame(content,options) ]);
    this.next();
  },
  error: function( content, options ) {
    var options = jQuery.extend({
      href:       'error',
      title:      'Error',
      class:      'error'
    }, options);
    this.push(content, options);
  },
  newBackButton: function(title) {
    return(
      { tagName: 'li', childNodes: [
        { tagName: 'a', class: 'back', href: '#', innerHTML: 'back' }
      ]}
    );
  },
  newFrame: function(content,options) {
    var options = jQuery.extend({
      href:       '/dashboard',
      title:      'Dashboard'
    }, options);
    return(
      { tagName: 'div', class: 'frame ' + options.class, href: options.href, title: options.title, innerHTML: content }
    );
  },
  pop: function() {
    this.prev();
    setTimeout( function() {
      Toolbox.last().remove();
      Toolbox.setTitle();
    }, 500);
  },
  popAndRefreshLast: function() {
    this.last().prev().refresh();
    this.pop();
  },
  popAndUpdateWith: function(content,options) {
    var options = jQuery.extend({ content: content }, options);
    this.last().prev().update(options);
    this.pop();
  },
  updateLastFrame: function(content,options) {
    var options = jQuery.extend({
      title:      '[No Title]'
    }, options);
    this.last().html(content);
  },
  setTitle: function() {
    return this.element().find('> div.head span.title').html( Toolbox.last().attr('title'));
  },
  setStatus: function(status) {
    return this.element().find('> div.foot span.status').html(status);
  },
  frames: function() {
    return this.body().find('> div.content > div.frame');
  },
  frameByHref: function(href) {
    return this.element().find('> div.body > div.content > div.frame[@href=' + href + ']')
  },
  scroller: function() {
    return $('div#toolbox > div.body');
  },
  last: function() {
    return this.scroller().find('> div.content > div.frame:last');
  },
  body: function() {
    return this.element().find('> div.body')
  },
  sidebar: function() {
    return this.element().find('> div.sidebar')
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
  },
  minimize: function() {
    if (this.minimized) {
      this.unminimize();
    } else {
      this.oldHeight = this.element().height();
      this.sidebarOff(function() {
        Toolbox.element().animate(
          { height: Toolbox.decorationHeight()-1}, 
          { duration: 700, complete: function() {
            Toolbox.body().hide();
            Toolbox.sidebar().hide();
          }}
        )
      });
      this.minimized = true;
    }
  },
  sidebarOn: function(after) {
    if (this.sidebarVisible) 
      return this.sidebar();
    this.sidebarVisible = true;
    return this.sidebar().show().animate(
      { left: '-='+(Toolbox.sidebar().width()+23)},
      { duration: 500, complete: after }
    )
  },
  sidebarOff: function(after) {
    if (!this.sidebarVisible)  // And if it's already off?
      return this.sidebar();   //  - I just walk away!
    this.sidebarVisible = false;
    return this.sidebar().animate(
      { left: '+='+(Toolbox.sidebar().width()+23)},
      { duration: 500, complete: after }
    );
  },
  sidebarToggle: function(after) {
    if (this.sidebarVisible)
      return this.sidebarOff(after)
    else
      return this.sidebarOn(after)
  },
  unminimize: function() {
    if (!this.minimized) {
      this.minimize();
    } else {
      Toolbox.body().show();
      Toolbox.setSizes();
      this.element().animate(
        { height: this.oldHeight || 400}, 
        { complete: function() { Toolbox.sidebarOn() }}
      );
      this.minimized = false;
    }
  },
  maximize: function() {
    console.debug("maximizing window");
  }


};


jQuery.fn.update = function(options) {
  var options = jQuery.extend({ title: '[No Title]' }, options);
  return $(this)
    .attr('title',options.title)
    .html(options.content);
}
jQuery.fn.refresh = function() {
  if ($(this).hasClass('frame'))
    var href = $(this).attr('href')
  else
    var href = $(this).parents('div.frame').attr('href');
  if (href) {
    $.ajax({
      url: href + '?refresh=1',
      type: 'GET',
      dataType: 'script'
    });
  }
}

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
    console.debug("Ajax loading: ", $(this).attr('href'));
    $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      dataType: 'script'
    });
  });
  return $(this);
};

jQuery.fn.ajaxifyForm = function() {
  if ($(this).attr('enctype') == "multipart/form-data") {
    name_and_id = "iframe_for_" + $(this).attr('id');
    $(this).appendDom([
      {tagName: 'iframe', name: name_and_id, id: name_and_id, 
       src: 'about:blank', style: "width:1px;height:1px;border:0px" }
    ]);
    action = $(this).attr('action');
    if (action.match(/\?/))
      $(this).attr('action', action + '&iframe_remote=1&format=js');
    else
      $(this).attr('action', action + '?iframe_remote=1&format=js');
    return $(this);
  } else {
    // Standard Form
    return $(this).ajaxForm({dataType: 'script'});
  }
};
