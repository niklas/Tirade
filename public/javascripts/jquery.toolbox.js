
var Toolbox = {
  findOrCreate: function() {
    if ( this.element().length == 0 ) {
      $('body').appendDom(Toolbox.Templates.toolbox);
      $('body #toolbox_body')
        .dialog({
          closeOnEscape: false,
          minHeight: 400,
          minWidth: 300,
          title: 'Toolbox Dialog',
          dragStart: function() { Toolbox.body.css('overflow-x', 'auto')},
          dragStop:  function() { Toolbox.body.css('overflow-x', 'hidden')},
          drag: Toolbox.callback.drag,
          resizeStop: Toolbox.callback.resized
        }).parent().attr('id', 'toolbox');

      this.sideBarVisible = false;
      this.setup();
      Toolbox.callback.drag();

      $.ui.frame("preparing Toolbox..").appendTo( this.content() );
      this.expireBehaviors();
      this.applyBehaviors();
      this.element().show();
    };
    this.setSizes();
    return this.element();
  },
  setup: function() {
    this.body = $('div#toolbox_body');

    this.footer = $('<div />')
      .addClass('ui-widget-header ui-corner-all footer')
      .attr('id', 'toolbox_footer')
      .insertAfter(Toolbox.body);

    this.header = this.element().find('> div.ui-widget-header.ui-dialog-titlebar:first').addClass('header');

    this.sideBar = $('<div />')
      .addClass('sidebar left ui-widget-content')
      .attr('id', 'toolbox_sidebar')
      .appendTo('body');

    this.history = $('<ul />')
      .addClass('history list records')
      .appendTo(Toolbox.sideBar);

    this.clipboard = $('<ul />')
      .addClass('clipboard list records')
      .appendTo(Toolbox.sideBar);

    this.sideBarActions = $('<div />')
      .addClass('ui-widget-header ui-corder-all actions')
      .appendTo(Toolbox.sideBar);

    this.toggleEditGridButton = $.ui.button({class: 'toggle edit grid', text: 'Toggle Edit Layout', icon: 'pencil'})
      .appendTo(Toolbox.sideBarActions)
      .toggleEditPage();

    this.refreshPageButton = $.ui.button({class: 'refresh_page', text: 'Refresh Page', icon: 'arrowrefresh-1-w'})
      .click(function(e) { $.get('/') })
      .appendTo(Toolbox.sideBarActions);

    this.toggleSideBarButton = $.ui.button({class: 'toggle-sidebar', icon: 'power', text: 'toggle sidebar'})
      .mousedown(function(ev) { ev.stopPropagation(); })
      .click(function(event) {
         if (Toolbox.sideBarVisible) {
           Toolbox.sideBarOff()
           Toolbox.toggleSideBarButton.removeClass('ui-state-active');
         } else {
           Toolbox.sideBarOn()
           Toolbox.toggleSideBarButton.addClass('ui-state-active');
         }
         return false;
      })
      .appendTo(Toolbox.footer);

    this.backButton = $.ui.button({icon: 'circle-triangle-w', text: 'back', class: 'back'})
      .click( function(event) { 
        event.preventDefault();
        Toolbox.pop() 
        return false;
      })
      .appendTo(Toolbox.header);

    this.toggleSizeButton = $.ui.button({icon: 'arrow-4-diag', text: 'maximize', class: 'min-max' })
      .toggle(Toolbox.maximize, Toolbox.unmaximize)
      .appendTo(Toolbox.header);

  },
  applyBehaviors: function() {
    this.body.serialScroll({
      target: 'div.content',
      step: 1, cycle: false,
      lazy: true,
      items: 'div.frame',
    onBefore: function() { 
      Toolbox.body.css('overflow-x', 'auto'); 
      return true  
  },
      onAfter:  function() { Toolbox.body.css('overflow-x', 'hidden'); return true},
      axis: 'x',
      duration: 300
    })

    this.body.bind('prev.serialScroll', this.refreshBackButton );
    this.body.bind('next.serialScroll', this.refreshBackButton );
    this.refreshBackButton();

    // Set Title of last frame
    this.frames(':not(:first)').livequery(function() { 
      Toolbox.setTitle();
    });

    this.linkBar().livequery(function() { 
      if ($(this).find('> li > a.back').length == 0) {
        $(this).appendDom(Toolbox.Templates.backButton)
      }
      $(this).addClass('ui-widget-header').slideUp().addRESTLinks($(this).parents('div.frame'));
      Toolbox.head().unbind('mouseenter').mouseenter(
        function() { Toolbox.linkBar().stop().slideDown('fast') }
      );
      Toolbox.last().unbind('mouseenter').mouseenter(
        function() { Toolbox.linkBar().pause(300).stop().slideUp('slow') }
      );
    });

    // Keep track of frames in history
    this.frames().livequery(function() { 
      var frame = $(this);
      var href = frame.attr('href');
      Toolbox.history.appendDom(
        Toolbox.Templates.historyItem( frame.attr('title'), href )
      );
    });

    // Ajaxify forms
    this.frames(' form').livequery(function() {
      $(this)
        .each( function() { this.action += '.js'; })
        .ajaxForm({
          dataType: 'script',
          beforeSubmit: function() {
            Toolbox.beBusy("submitting " + Toolbox.last().attr('title'))
          }
        })
        .appendDom([
          {tagName: 'input', type: 'hidden', name: 'context_page_id', value: $('body > div.page').resourceId() }
        ]);
    });

    // Accordion, open in last used section
    this.accordion().livequery(function() { 
      active = 0;
      if (name = Toolbox.activeSectionName) { 
        active = '[name=' + name + ']' 
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
      var s = $(this);
      $.timer(300,function(timer) {
        timer.stop();
        Toolbox.accordion().scrollTo(s, 500);
        $(this).addClass('scrolled');
      })
    });

    // Init and Auto-Refresh the Dashboard
    Toolbox.frameByHref('/dashboard').refresh();
    //$.timer(60 * 1000,function(timer) {
    //  if (!Toolbox.element()) {
    //    timer.stop();
    //  } else {
    //    if (!Toolbox.minimized) {
    //      Toolbox.frameByHref('/dashboard').refresh();
    //    }
    //  }
    //});
    this.frames(' textarea.markitup.textile').livequery(function() {
      $(this).markItUp(myTextileSettings);
    });
    this.frames(' textarea:not(.markitup)').livequery(function() {
      if ( !$(this).data('hasElastic') )
        $(this).elastic().data('hasElastic', true);
    });
    this.last(' div.live_search input.search_term').livequery(function() {
      var field = $(this);
      $(this).attr("autocomplete", "off").typeWatch({
        wait: 500,
        captureLength: 2,
        callback: function(val) {
          $.ajax({
            data: { 'search[term]' : encodeURIComponent(val) },
            url: field.attr('href')
          });
        }
      })
    });
    this.last(' div.live_search.polymorphic select.polymorph_search_url').livequery(function() { 
      var field = $(this);
      $(this).change(function() {
        $(this).siblings('input.search_term:first')
          .attr('href',field.val())
          .val('');
      })
    });

    this.last(' ul.list').livequery(function() { $(this).unbind('dblclick').dblclick(function(e) {
      $(e.target).find('a:first').click()
    })});

    this.last(' di.association.one dd > ul.list').livequery(function() { $(this).hasOneEditor() });
    this.last(' di.association.many dd > ul.list').livequery(function() { $(this).hasManyEditor() });

    // mark empty association lists
    this.last(' di.association dd > ul.list:not(:has(li))').livequery(function() {
      $(this).addClass('empty');
    });

    // search results items
    this.last(' di.association dd div.live_search div.search_results ul.list li').livequery(function() {
      item = $(this);
      association_list = item.parents('div.live_search').siblings('ul.list.ui-droppable:first');
      item 
        .find('img.association').remove().end()
        .appendDom(Toolbox.Templates.addButton)
        .find('img.add').click(function(event) {
          if (association_list.parents('di.association:first').is('.one')) {
            association_list.find('li').remove();
          }
          item.clone().appendTo(association_list);
        })
    });


    // Double click selectable attributes to edit them
    this.last(' di.selectable').livequery(function() {
      $(this).dblclick( function() {
        $(this).parents('div.frame').find('ul.linkbar li a.edit:first').click();
      });
    });

    // Part assignment form
    this.last(' form.edit_rendering').livequery(function() {
      var form = $(this);
      renderingAssignmentFormUpdate = function (e) {
        form.find('h3.what + dl')
          .find('> di:not(.assignment)').hide()
            .find(':input').disable();
        form.find('di.association.one.content .live_search').hide();
        form.find('div.scopes').hide().find(':input').disable();
        form.find('div.scopes .define :input').hide();
        form.find('div.scopes .define a.create_scope').hide();
        switch (form.find('select#rendering_assignment').val()) {
          case 'none':
            break;
          case 'fixed':
            form.find('di.association.one.content').show().find('input.association_id, input.association_type').enable();
            break;
          case 'by_title_from_trailing_url':
            form.enableField('content_type');
            break;
          case 'scope':
            var t = form.enableField('content_type').val();
            var scope = form.find('div.scopes.' + t).show();
            scope.find(' > di :input').enable();  /* enable non-filtering scopes like order etc */
            break;
        }
      }
      renderingAssignmentFormUpdate();
      form.find('select#rendering_assignment').change( renderingAssignmentFormUpdate );
      form.find('select#rendering_content_type').change( renderingAssignmentFormUpdate );

      $('<a href="#" class="remove">Remove</a>').appendTo(form.find('div.pool di dt'));

      form.find('a.add').unbind('click').click( function(ev) {
        var link = $(ev.target);
        var define = link.parents('.define');
        var meta = define.metadata();
        var pool = define.siblings('div.pool');

        define.find(':input').show();
        var select_column = define.find('select[name=select_column]');
        var select_comparison = define.find('select[name=select_comparison]');
        var ok = define.find('.create_scope').show();

        select_column.find('option').remove();
        $.each(meta.columns, function() {
          $('<option value ="' + this.name + '">' + this.name +'</option>').appendTo(select_column)
        })

        var updateComparisons = function() {
          select_comparison.find('option').remove();
          $.each(meta.comparisons[ select_column.val() ], function() {
            $('<option value ="' + this + '">' + this +'</option>').appendTo(select_comparison)
          }) 
        }

        select_column.unbind('change').change( updateComparisons );
        updateComparisons();

        ok.click( function(ev) {
          var scope_name = select_column.val() + '_' + select_comparison.val();
          var scope = pool.find('di.' + scope_name).clone()
          scope
            .find(':input').enable().end()
            .find('a.remove').click(function() { scope.remove() }).end()
            .insertAfter(define);
          ok.hide();
          define.find(':input').hide();
          ev.preventDefault();
          return false;
        });

      });
    });


    this.last(' a.toggle_live_search').livequery('click', function(e) {
      e.preventDefault();
      $(this).siblings('.live_search').toggle();
    });

    // redirect the Submit button from bottomLinkBar
    this.last(' form:has(input.submit:visible)').livequery(function() {
      Toolbox.bottomLinkBar().appendDom(
        Toolbox.Templates.submitButton
      );
      var orgbutton = $(this).find('input.submit').hide();
      Toolbox.bottomLinkBar('> li.submit > a.submit')
        .text( orgbutton.attr('value') )
        .click(function(e) {
          e.preventDefault();
          form = Toolbox.last(' form');
          form[0].clk = orgbutton[0];
          form.submit();
        });
    });


    // Ajax callbacks
    this.element()
      .ajaxStop(function() {
        Toolbox.element().unBusy()
      });

    this.setSizes();
  },
  expireBehaviors: function() {
    this.frames().expire();
    this.accordion().expire();
    this.element(" a.back[href='#']").expire();
    this.frames(':not(:first)').expire();
    this.frames(' form').expire();
    this.last(' input.search_term').expire();
    this.last(' div.search_results ul.list li').expire();
    this.last(' di.selectable').expire();
    this.last(' label + ul.list li').expire();
    this.last(' label + ul.list').expire();
    this.last(' label + ul.association.one li').expire();
    this.last('>ul.bottom_linkbar li.submit a.submit').expire();

  },
  setSizes: function() {
    /* this.scroller().height( this.bodyHeight() );
    this.busyBox().height( this.bodyHeight() );
    this.accordion().height(
      Toolbox.body().height() - Toolbox.linkBar().height()
      ); */
  },
  bodyHeight: function() {
    return this.element().height() - this.decorationHeight()
  },
  decorationHeight: function() {
    return this.element(' > div.head').height() + this.element(' > div.foot').height()
  },
  push: function(content,options) {
    $.ui.frame(content, options).appendTo( this.content() );
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
  // 
  surrounds: function(position) {
    return(
      Toolbox.element().surrounds(position) ||
      Toolbox.sideBar.surrounds(position)
    );
  },
  pop: function() {
    if ( this.frames().length > 1 ) {
      $('body').applyRoles();
      this.prev();
      setTimeout( this.removeLastFrame, 500 );
    }
  },
  removeLastFrame: function() {
    Toolbox.last().remove();
    Toolbox.history.find(' li:not(:first):last').remove();
    Toolbox.setTitle();
    Toolbox.refreshBackButton();
  },
  refreshBackButton: function() {
    if ( Toolbox.frames().length > 1 )
      Toolbox.backButton.removeClass('ui-state-disabled')
    else
      Toolbox.backButton.addClass('ui-state-disabled')
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
    this.setTitle(options.title);
  },
  setTitle: function(title) {
    return $('span#ui-dialog-title-toolbox_body').html( title || Toolbox.last().attr('title'));
  },
  setClipboard: function(html) {
    return this.clipboard.html(html);
  },
  setStatus: function(status) {
    return this.element('> div.foot span.status').html(status);
  },
  setBusyText: function(text) {
    return this.busyBox('> span.message').html(text);
  },
  beBusy: function(message) {
    return this.element().beBusy(message);
  },
  unBusy: function() {
    return this.element().unBusy();
  },
  beExclusiveDroppable: function() {
    if ( !this.exclusiveDroppable ) {
      this.otherDroppables()
        .droppable("disable")
        .removeClass('hover')
        .removeClass('drop-invite');
      this.exclusiveDroppable = true;
    }
  },
  unExclusiveDroppable: function() {
    if ( this.exclusiveDroppable ) {
      this.otherDroppables().droppable("enable");
      this.exclusiveDroppable = false;
    }
  },
  beGhost: function() {
    if ( !this.ghosted ) {
      this.element().animate({opacity: 0.42, duration: 1000});
      this.ghosted = true;
    }
  },
  unGhost: function() {
    if ( this.ghosted ) {
      this.element().animate({opacity: 1, duration: 1000});
      this.ghosted = false;
    }
  },
  frames: function(rest) {
    return this.content('> div.frame'+(rest||''));
  },
  frameByHref: function(href,rest) {
    return this.frames('[href=' + href + ']'+(rest||''))
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
  head: function(rest) {
    return this.element('> div.ui-dialog-titlebar:first'+(rest||''))
  },
  busyBox: function(rest) {
    return this.element('> div.busy'+(rest||''))
  },
  element: function(rest) {
    return $('div#toolbox' +(rest||''));
  },
  next: function() {
    return this.body.trigger('next');
  },
  prev: function() {
    return this.body.trigger('prev');
  },
  close: function() {
    this.expireBehaviors();
    this.element().remove();
    $('div.active').removeClass('active');
  },
  otherDroppables: function() {
    return this.element().siblings().find('.ui-droppable')
  },
  accordion: function() {
    return this.last(' div.accordion')
  },
  openSectionByName: function(name) {
    selector = '[name='+name+']:not(.selected)';
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
      this.sideBarOff(function() {
        Toolbox.element().animate(
          { height: Toolbox.decorationHeight()-1}, 
          { duration: 700, complete: function() {
            Toolbox.body.hide();
            Toolbox.sideBar.hide();
          }}
        )
      });
      this.minimized = true;
    }
  },
  sideBarOn: function(after) {
    if (this.sideBarVisible) 
      return this.sideBar;
    this.sideBarVisible = true;
    return this.sideBar.show().animate(
      { left: '-='+(Toolbox.sideBar.width())},
      { duration: 500, complete: after }
    )
  },
  sideBarOff: function(after) {
    if (!this.sideBarVisible)  // And if it's already off?
      return this.sideBar;   //  - I just walk away!
    this.sideBarVisible = false;
    return this.sideBar.animate(
      { left: '+='+(Toolbox.sideBar.width())},
      { duration: 500, complete: after }
    );
  },
  sideBarToggle: function(after) {
    if (this.sideBarVisible)
      return this.sideBarOff(after)
    else
      return this.sideBarOn(after)
  },
  linkBar: function() {
    return(Toolbox.last(' ul.linkbar'));
  },
  linkBarOn: function(after) {
    if (this.linkBar().css('top') != '0px') {
      var h = this.linkBar().height();
      this.last().animate({paddingTop: h, height: this.bodyHeight() - h}, {duration: 500 })
        .find('ul.linkbar') .animate({top:'0px'}, { duration: 300 });
    }
  },
  linkBarOff: function(after) {
    if (this.linkBar().css('top') == '0px') {
      var h = this.linkBar().height();
      this.last() .animate({paddingTop: '0', height: this.bodyHeight() }, { duration: 500 })
        .find('ul.linkbar').animate({top: -(2*h)}, {duration: 300 });
    }
  },
  unminimize: function() {
    if (!this.minimized) {
      this.minimize();
    } else {
      Toolbox.body.show();
      Toolbox.setSizes();
      this.element().animate(
        { height: this.oldHeight || 400}, 
        { complete: function() { Toolbox.sideBarOn() }}
      );
      this.minimized = false;
    }
  },
  storeSizeAndPosition: function() {
    this.element()
      .data('height',   this.element().height())
      .data('width',    this.element().width())
      .data('position', this.element().position())
  },
  maximize: function() {
    Toolbox.storeSizeAndPosition();
    Toolbox.element().animate(
      {height: '100%', width: '75%', top: 0, left: '25%'},
      'slow', 'linear', Toolbox.callback.resized
    );
  },
  unmaximize: function() {
    var position = Toolbox.element().data('position');
    Toolbox.element().animate({
      height: Toolbox.element().data('height'), 
      width:  Toolbox.element().data('width'), 
      top: position.top, 
      left: position.left
    },'fast', 'linear', Toolbox.callback.resized);
  },

  bottomLinkBar: function(rest) {
    if (this.last('>ul.bottom_linkbar').length == 0) {
      this.last().appendDom(Toolbox.Templates.bottomLinkBar);
    };
    return this.last('>ul.bottom_linkbar' + (rest||''));
  },

  callback: {
    resized: function(e,ui) {
      Toolbox.frames().height(Toolbox.body.height());
      Toolbox.frames().width(Toolbox.body.width());
      Toolbox.body[0].scrollLeft = Toolbox.last()[0].offsetLeft;
    },
    drag: function(e, ui) {
      if (Toolbox.sideBarVisible) {
        Toolbox.sideBar[0].style.left = (Toolbox.element().position().left - Toolbox.sideBar.width()) + 'px';
        Toolbox.sideBar[0].style.top =  (Toolbox.element().position().top + 42) + 'px';
      } else {
        Toolbox.sideBar[0].style.left = (Toolbox.element().position().left) + 'px';
        Toolbox.sideBar[0].style.top =  (Toolbox.element().position().top + 42) + 'px';
      }
    }
  }

};


Toolbox.Templates = {
  addButton: [ 
    { tagName: 'img', src: '/images/icons/small/plus.gif', class: 'association add' } 
    ],
  removeButton: [
    { tagName: 'img', src: '/images/icons/small/x.gif', class: 'association remove' }
  ],
  backButton: [
    { tagName: 'li', childNodes: [
      { tagName: 'a', class: 'back', href: '#', innerHTML: 'back' }
    ]}
  ],
  historyItem: function(title, href) {
    return([
      { tagName: 'li', href: href, class: 'jump', innerHTML: title }
    ]);
  },
  bottomLinkBar: [
    {tagName: 'ul', class: 'bottom_linkbar' }
  ],
  submitButton: [
    { tagName: 'li', class: 'submit', childNodes: [
      { tagName: 'a', class: 'submit', href: '#' }
    ] }
  ],
  toolbox: [
    { tagName: 'div', id: 'toolbox_body', class: 'body', childNodes: [
      { tagName: 'div', class: 'content', id: 'toolbox_content' }
    ]},
  ],
}

jQuery.fn.update = function(options) {
  var options = jQuery.extend({ title: '[No Title]' }, options);
  $(this)
    .attr('title',options.title)
    .html(options.content);
  Toolbox.setTitle();
  return $(this);
}
jQuery.fn.refresh = function() {
  if ($(this).hasClass('frame'))
    var href = $(this).attr('href')
  else
    var href = $(this).parents('div.frame').attr('href');
  if (href) {
    $.ajax({
      url: href + '?refresh=1',
      type: 'GET'
    });
  }
}

jQuery.fn.useToolbox = function(options) {
  var defaults = {
    start: function() {}
  };
  var options = $.extend(defaults, options);
  if (options.icon) {
    $(this).addClass('ui-icon ui-icon-' + options.icon)
  }
  if ( !$(this).hasClass("without_toolbox") ) {
    return $(this).resourcefulLink({
      start: function(event) {
        Toolbox.findOrCreate();
        Toolbox.beBusy('Loading');
        options.start(event);
      }
    })
  } else {
    return $(this);
  }
};

jQuery.fn.frameInToolbox = function(options) {
  var defaults = {
  };
  var options = $.extend(defaults, options);
};
jQuery.fn.formInFrameInToolbox = function(options) {
  var defaults = {
  };
  var options = $.extend(defaults, options);
};

jQuery.ui.button = function(options) {
  var defaults = {
    hover: true,
    icon: 'help',
    text: 'Help',
    selectable: false
  };
  var options = $.extend(defaults, options);
  var button = $('<a href="#" />')
    .addClass('ui-corner-all ui-button ' + options.class)
    .attr('role', 'button');
  if (options.hover) button.hover(
       function() { button.addClass('ui-state-hover'); },
       function() { button.removeClass('ui-state-hover'); }
     );
  $('<span/>')
    .addClass('ui-icon ui-icon-' + options.icon)
    .text(options.text)
    .appendTo(button);
  if (!options.selectable) button.disableSelection();
  return button
};

jQuery.ui.frame = function(content, options) {
  var defaults = {
    href: '/dashboard',
    title: 'Dashboard'
  };
  var options = $.extend(defaults, options);
  class = options.class ? 'frame ' + options.class : 'frame'

  return $('<div/>')
    .addClass('frame')
    .addClass(options.class)
    .attr('role', 'frame')
    .attr('title', options.title)
    .attr('href', options.href)
    .html(content);
};
