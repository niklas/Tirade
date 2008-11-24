
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
    this.element(" a.back[@href='#']").livequery(function() { 
      $(this).click(function(event) { 
        event.preventDefault();
        $('div.active').removeClass('active');
        Toolbox.pop() 
      })
    });

    // Set Title of last frame
    this.frames(':not(:first)').livequery(function() { 
      Toolbox.setTitle();
    });
    this.frames(' form').livequery(function() { $(this).ajaxifyForm() });
    this.linkBar().livequery(function() { 
      Toolbox.setTitle();
      Toolbox.linkBarOn();
      if ($(this).find('> li > a.back').length == 0) {
        $(this).appendDom([Toolbox.newBackButton()])
      }
    });

    // Keep track of frames in history
    this.frames().livequery(function() { 
      var frame = $(this);
      Toolbox.history().appendDom([
        Toolbox.newHistoryItem( frame.attr('title'), frame.attr('href') )
      ]);
    });
    this.history('> li > a.jump').livequery('click', function(event) {
      event.preventDefault();
      console.debug("clicked to jump to", $(this).html())
    });


    // Accordion, open in last used section
    this.accordion().livequery(function() { 
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
    this.accordion(' h3.selected').livequery(function() { 
      console.debug('selected', this);
      var s = $(this);
      $.timer(300,function(timer) {
        timer.stop();
        Toolbox.accordion().scrollTo(s, 500);
        $(this).addClass('scrolled');
      })
    });

    // Init and Auto-Refresh the Dashboard
    Toolbox.frameByHref('/dashboard').refresh();
    $.timer(60 * 1000,function(timer) {
      if (!Toolbox.element()) {
        timer.stop();
      } else {
        if (!Toolbox.minimized) {
          Toolbox.frameByHref('/dashboard').refresh();
        }
      }
    });
    this.frames(' textarea').livequery(function() {
      $(this).elastic();
    });
    this.last(' input.search_term').livequery(function() {
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

    // list with single association
    this.last(' label + ul.association.one li').livequery(function() {
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
    this.last(' label + ul.list').livequery(function() {
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
    this.last(' label + ul.list li').livequery(function() {
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


    // Double click selectable attributes to edit them
    this.last(' di.selectable').livequery(function() {
      $(this).dblclick( function() {
        $(this).parents('div.frame').find('ul.linkbar li a.edit:first').click();
      });
    });



    // Copy the Submit button to bottomLinkBar
    this.last(' xxxxxxxxxxxxform').livequery(function() {
      if ($(this).find('input.submit').length > 0) {
        Toolbox.createBottomLinkBar().appendDom([
          { tagName: 'li', class: 'submit' }
        ]);
        Toolbox.last(' form input.submit:first').appendTo(
          Toolbox.createBottomLinkBar().find('li.submit')
        );
      }
    });



    this.setSizes();
  },
  expireBehaviors: function() {
    this.frames().expire();
    this.accordion().expire();
    this.element(" a.back[@href='#']").expire();
    this.frames(':not(:first)').expire();
    this.frames(' form').expire();
    this.linkBar().expire();
    this.history('> li > a.jump').expire();
    this.last(' input.search_term').expire();
    this.last(' div.search_results ul.list li').expire();
    this.last(' di.selectable').expire();
    this.last(' label + ul.list li').expire();
    this.last(' label + ul.list').expire();
    this.last(' label + ul.association.one li').expire();
  },
  setSizes: function() {
    this.scroller().height( this.bodyHeight() );
    this.busyBox().height( this.bodyHeight() );
    this.frames().height( Toolbox.body().height() );
    this.accordion().height(
      Toolbox.body().height() - Toolbox.linkBar().height()
    );
    this.scroller().scrollTo('div.frame:last',{axis:'x'});
  },
  bodyHeight: function() {
    return this.element().height() - this.decorationHeight()
  },
  decorationHeight: function() {
    return this.element(' > div.head').height() + this.element(' > div.foot').height()
  },
  push: function(content,options) {
    this.content()
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
      Toolbox.history(' li:not(:first):last').remove();
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
    return this.element('> div.head span.title').html( Toolbox.last().attr('title'));
  },
  setStatus: function(status) {
    return this.element('> div.foot span.status').html(status);
  },
  frames: function(rest) {
    return this.content('> div.frame'+(rest||''));
  },
  frameByHref: function(href,rest) {
    return this.frames('[@href=' + href + ']'+(rest||''))
  },
  scroller: function(rest) {
    return this.element('> div.body'+(rest||''));
  },
  content: function(rest) {
    return this.scroller('> div.content' +(rest||''));
  },
  last: function(rest) {
    return this.frames(':last' +(rest||''));
  },
  body: function(rest) {
    return this.element('> div.body'+(rest||''))
  },
  sidebar: function(rest) {
    return this.element('> div.sidebar'+(rest||''))
  },
  clipboard: function(rest) {
    return this.sidebar('> ul.clipboard'+(rest||''))
  },
  history: function(rest) {
    return this.sidebar('> ul.history'+(rest||''))
  },
  busyBox: function(rest) {
    return this.element('> div.busy'+(rest||''))
  },
  element: function(rest) {
    return $('div#toolbox' +(rest||''));
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
    return this.last(' div.accordion')
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
  linkBar: function() {
    // Toolbox.last('ul.linkbar')
    return(Toolbox.last(' ul.linkbar'));
  },
  linkBarOn: function(after) {
    var h = this.linkBar().height();
    this.last().animate({paddingTop: h}, {duration: 500, complete: function() { Toolbox.setSizes() }})
      .find('ul.linkbar') .animate({top:'0px'}, { duration: 300 });
  },
  linkBarOff: function(after) {
    var h = this.linkBar().height();
    this.last() .animate({paddingTop: '0'}, { duration: 500, complete: function() { Toolbox.setSizes() } })
      .find('ul.linkbar').animate({top: -(2*h)}, {duration: 300 });
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
  },

  createBottomLinkBar: function() {
    if (this.last('>ul.bottom_linkbar').length == 0) {
      this.last().appendDom([
        {tagName: 'ul', class: 'bottom_linkbar' }
      ]);
    };
    return this.last('>ul.bottom_linkbar');
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
  // Set context_page_id so that rails know on which page we are on
  $(this).appendDom([
    {tagName: 'input', type: 'hidden', name: 'context_page_id', value: $('body > div.page').resourceId() }
  ]);
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
