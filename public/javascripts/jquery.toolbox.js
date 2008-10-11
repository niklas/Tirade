
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
      $('div#toolbox > div.body > div.content > div.frame form').livequery(function() { $(this).ajaxifyForm() });
      $('div#toolbox > div.body > div.content > div.frame > ul.linkbar').livequery(function() { 
        console.debug("New Linkbar!");
        if ($(this).find('> li > a.back').length == 0) {
          $(this).appendDom([Toolbox.newBackButton()])
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
    var options = jQuery.extend({
      href:       '/dashboard',
      title:      '[No Title]'
    }, options);
    this.scroller().find('> div.content')
      .appendDom([
        {tagName: 'div', class: 'frame', href: options.href, innerHTML: content }
      ]);
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
    this.frameByHref(href).html(content).css('background','yellow');
    this.setTitle(options.title);
  },
  frameByHref: function(href) {
    return this.element().find('> div.body > div.content > div.frame[@href=' + href + ']')
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
      this.sidebar().animate(
        { left: ('+='+Toolbox.sidebar().width()) },
        { complete: function() {
          Toolbox.element().animate(
            { height: Toolbox.decorationHeight()-1}, 
            { complete: function() {
              Toolbox.body().hide();
              Toolbox.sidebar().hide();
            }}
          )
        }}
      );
      this.minimized = true;
      console.debug("minimized window");
    }
  },
  sidebarOn: function() {
  },
  sidebarOff: function() {
  },
  unminimize: function() {
    if (!this.minimized) {
      this.minimize();
    } else {
      Toolbox.body().show();
      Toolbox.setSizes();
      this.element().animate(
        { height: this.oldHeight || 400}, 
        { complete: function() {
          Toolbox.sidebar().show().animate(
            { left: ('-='+Toolbox.sidebar().width())}
          )
          }}
      );
      this.minimized = false;
      console.debug("unminimized window");
    }
  },
  maximize: function() {
    console.debug("maximizing window");
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
