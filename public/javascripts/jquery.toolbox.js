
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
          { tagName: 'div', class: 'sidebar left', childNodes: [
            { tagName: 'ul', class: 'history' },
            { tagName: 'ul', class: 'clipboard list' }
          ] },
          { tagName: 'div', class: 'busy', childNodes: [
            { tagName: 'span', class: 'message', innerHTML: 'Loading' }
          ] },
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
      this.expireBehaviors();
      this.applyBehaviors();

    };
    this.setSizes();
    return this.element();
  },
  applyBehaviors: function() {
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
        // Buttons
      .find(' > div.head > span.buttons')
        .find('> img.close').click(function() { Toolbox.close() }).end()
        .find('> img.min').click(function() { Toolbox.minimize() }).end()
        .find('> img.max').click(function() { Toolbox.maximize() }).end()
      .end()
      .show();
    // Back button
    $("div#toolbox a.back[@href='#']").livequery(function() { 
      $(this).click(function(event) { 
        event.preventDefault();
        $('div.active').removeClass('active');
        Toolbox.pop() 
      })
    });

    // Set Title of last frame
    $('div#toolbox > div.body > div.content > div.frame:not(:first)').livequery(function() { 
      Toolbox.setTitle();
    });
    $('div#toolbox > div.body > div.content > div.frame form').livequery(function() { $(this).ajaxifyForm() });
    $('div#toolbox > div.body > div.content > div.frame > ul.linkbar').livequery(function() { 
      Toolbox.setTitle();
      if ($(this).find('> li > a.back').length == 0) {
        $(this).appendDom([Toolbox.newBackButton()])
      }
    });

    // Keep track of frames in history
    $('div#toolbox > div.body > div.content > div.frame').livequery(function() { 
      var frame = $(this);
      Toolbox.history().appendDom([
        Toolbox.newHistoryItem( frame.attr('title'), frame.attr('href') )
      ]);
    });
    $('div#toolbox > div.sidebar > ul.history > li > a.jump').livequery('click', function(event) {
      event.preventDefault();
      console.debug("clicked to jump to", $(this).html())
    });


    // Accordion, open in last used section
    $('div#toolbox > div.body > div.content > div.frame div.accordion').livequery(function() { 
      active = 0;
      if (name = Toolbox.activeSectionName) { 
        active = '[@name=' + name + ']' 
      };
      $(this).accordion({ 
        header: 'h3.accordion_toggle', 
        selectedClass: 'selected',
        autoHeight: false,
        alwaysOpen: false,
        active: active
      })
      .bind("accordionchange", function(event, ui) {
        if (ui.newHeader) {
          Toolbox.saveActive(ui.newHeader);
          //Toolbox.accordion().scrollTo(ui.newHeader, 500);
        }
      });
    });

    // Scroll to selected accordion section
    $('div#toolbox > div.body > div.content > div.frame:last div.accordion h3.selected').livequery(function() { 
      console.debug('selected', this);
      var s = $(this);
      $.timer(300,function(timer) {
        timer.stop();
        Toolbox.accordion().scrollTo(s, 500);
        $(this).addClass('scrolled');
      })
    });

    // Auto-Refresh the Dashboard
    $.timer(60 * 1000,function(timer) {
      if (!Toolbox.element()) {
        timer.stop();
      } else {
        if (!Toolbox.minimized) {
          Toolbox.frameByHref('/dashboard').refresh();
        }
      }
    });
    $('div#toolbox > div.body > div.content > div.frame textarea').livequery(function() {
      $(this).elastic();
    });
    $('div#toolbox div.frame:last input#search_term').livequery(function() {
      var url = $(this).attr('href');
      $(this).attr("autocomplete", "off").typeWatch({
        wait: 500,
        captureLength: 2,
        callback: function(val) {
          $.ajax({
            data: { 'search[term]' : encodeURIComponent(val) },
            dataType:'script', 
            url: url,
            complete: function() {
              Toolbox.last().find('div.search_results.many ul.list li')
                .appendDom([ { tagName: 'img', src: '/images/icons/small/plus.gif', class: 'association add' } ])
                .find('img.add').click(function(event) {
                  var item = $(this).parents('li');
                  item.clone().appendTo(item.parents('div.search_results').siblings('ul.list:first'));
                });
              Toolbox.last().find('div.search_results.one ul.list li')
                .appendDom([ { tagName: 'img', src: '/images/icons/small/plus.gif', class: 'association add' } ])
                .find('img.add').click(function(event) {
                  var item = $(this).parents('li');
                  var target = item.parents('div.search_results').siblings('ul.association:first');
                  target.html('');
                  item.clone().appendTo(target);
                });
            }
          });
        }
      })
    });

    // list with singel association
    $('div#toolbox div.frame:last label + ul.association.one li').livequery(function() {
      var item = $(this);
      item.find('img.association').remove();
      item.appendDom([ { tagName: 'img', src: '/images/icons/small/x.gif', class: 'association remove' } ]);
      item.find('img.remove').click(function(event) {
        item.parents('ul.association.one:first')
          .siblings('input.association_id:first').val('').end()
          .siblings('input.association_type:first').val('').end()
          .highlight().end()
        .remove();
      });
      if ( attrs = item.typeAndId() ) {
        item.parents('ul.association.one:first')
          .siblings('input.association_id:first').val(attrs.id).end()
          .siblings('input.association_type:first').val(attrs.type).end()
          .highlight();
      }
    });

    // List with associated elements
    $('div#toolbox div.frame:last label + ul.list').livequery(function() {
      var list = $(this);
      list.droppable({
        accept: function(draggable) { 
          return(
            draggable.is('li') &&
            draggable.parent()[0] != list[0]
          );
        },
        hoverClass: 'hover',
        activeClass: 'active-droppable',
        greedy: true,
        drop: function(e,ui) {
          $(ui.draggable).clone().appendTo(list);
        }
      });
    });
    $('div#toolbox div.frame:last label + ul.list li').livequery(function() {
      var item = $(this);
      item.find('img.association').remove();
      item.parents('ul.list').removeClass('empty')
      // clone hidden tag
        .siblings('input[@type=hidden][@value=empty]').clone().attr('value',item.resourceId()).appendTo(item);

      item.appendDom([ { tagName: 'img', src: '/images/icons/small/x.gif', class: 'association remove' } ]);
      item.find('img.remove').click(function(event) {
        item.remove();
        Toolbox.last().find('ul.list:not(:has(li))').addClass('empty');
      });
    });


    /*
    $('div#toolbox div.frame:last div.search_results ul.list li').livequery(function() {
      var item = $(this);
      item.find('img.association').remove();
      item.appendDom([ { tagName: 'img', src: '/images/icons/small/plus.gif', class: 'association add' } ]);
      item.find('img.add').click(function(event) {
        item.clone().appendTo(item.parents('div.search_results').siblings('ul.items'));
      });
    }); */



    this.setSizes();
    //$('div#toolbox > div.body > div.content > div.frame dd a.show').livequery(function() { 
    //  $(this).parent()
    //    .addClass('clickable')
    //    .click(function(event) {
    //      event.preventDefault();
    //      $(this).find('a.show').click();
    //    })
    //});
  },
  expireBehaviors: function() {
    $('div#toolbox > div.body > div.content > div.frame').expire();
    $('div#toolbox > div.body > div.content > div.frame div.accordion').expire();
    $("div#toolbox a.back[@href='#']").expire();
    $('div#toolbox > div.body > div.content > div.frame:not(:first)').expire();
    $('div#toolbox > div.body > div.content > div.frame form').expire();
    $('div#toolbox > div.body > div.content > div.frame > ul.linkbar').expire();
    $('div#toolbox > div.sidebar > ul.history > li > a.jump').expire();
    $('div#toolbox div.frame:last input#search_term').expire();
    $('div#toolbox div.frame:last div.search_results ul.list li').expire();
  },
  setSizes: function() {
    this.scroller().height( this.bodyHeight() );
    this.busyBox().height( this.bodyHeight() );
    $('div#toolbox > div.body > div.content > div.frame').height( Toolbox.body().height() );
    this.accordion().height(
      Toolbox.body().height() - Toolbox.last().find('ul.linkbar').height()
    );
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
  newHistoryItem: function(title, href) {
    return(
      { tagName: 'li', href: href, class: 'jump', innerHTML: title }
    );
  },
  newFrame: function(content,options) {
    var options = jQuery.extend({
      href:       '/dashboard',
      title:      'Dashboard'
    }, options);
    class = options.class ? 'frame ' + options.class : 'frame'
    return(
      { tagName: 'div', class: class, href: options.href, title: options.title, innerHTML: content }
    );
  },
  pop: function() {
    $('body').applyRoles();
    this.prev();
    setTimeout( function() {
      Toolbox.last().remove();
      Toolbox.history().find('li:not(:first):last').remove();
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
  clipboard: function() {
    return this.element().find('> div.sidebar > ul.clipboard')
  },
  history: function() {
    return this.sidebar().find('> ul.history')
  },
  busyBox: function() {
    return this.element().find('> div.busy')
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
    this.expireBehaviors();
    this.element().remove();
    $('div.active').removeClass('active');
  },
  accordion: function() {
    return this.last().find('div.accordion')
  },
  openSectionByName: function(name) {
    console.debug("openSectionByName",name);
    selector = '[@name='+name+']:not(.selected)';
    if (this.accordion().find(selector).length!=0) {
      return this.accordion().accordion('activate', selector);
    }
  },
  openPreferredSection: function() {
    if (name = this.lastSectionName ||
      this.last().prev().find('.selected.ui-accordion-header').attr('name')) {
      return this.openSectionByName(name);
    }
  },
  saveActive: function(element) {
    if (element) {
      if (name = element.attr('name')) {
        this.activeSectionName = name;
      } else {
        this.activeSectionName = element.find('.selected.ui-accordion-header').attr('name');
      }
    } else {
      this.saveActive( this.last() )
    }
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
    event.preventDefault();
    Toolbox.findOrCreate();
    Toolbox.busyBox().fadeIn('fast');
    $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      dataType: 'script',
      complete: function() { Toolbox.busyBox().fadeOut('fast') }
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
