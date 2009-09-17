/*jslint browser: true */
/*global jQuery, Routing */

(function($){
  if (!$.tirade) { $.tirade = {}; }
  $.tirade.resourceful = function(options) {
    return this;
  };

  $.extend( $.tirade.resourceful, {
    destroy: function(resource_name, id) {
      return $.ajax({
        url: Routing[resource_name + '_path']({id: id, format:'js', authenticity_token: $.tirade.resourceful.authToken() }),
        type: 'DELETE', data: ''
      });
    },
    destroyButton: function(resource_name, id) {
      return $.ui.button({
        icon: 'trash', text: 'Delete ' + resource_name,
        cssclass: 'delete'
      })
      .addClass(resource_name)
      .click(function(event) {
        if (confirm("Really delete?")) { $.tirade.resourceful.destroy(resource_name, id); }
        event.preventDefault(); event.stopPropagation();
        return false;
      });
    },
    doNew: function(resource_name, attributes) {
      attributes = $.extend({
        format: 'js',
        authenticity_token: $.tirade.resourceful.authToken()
      }, attributes);
      return $.ajax({
        url: Routing['new_' + resource_name + '_path'](attributes),
        type: 'GET'
      });
    },
    newButton: function(resource_name, attributes) {
      return $.ui.button({
        icon: 'plus', text: 'New ' + $.string(resource_name).capitalize().str, 
        cssclass: 'new'
      })
      .addClass(resource_name)
      .click(function(event) {
        $.tirade.resourceful.doNew(resource_name, attributes);
        event.preventDefault(); event.stopPropagation();
        return false;
      });
    },
    edit: function(resource_name, id, options) {
      var ajax_options = $.extend({}, options, {
        url: Routing['edit_' + resource_name + '_path']({id: id, format: 'js', authenticity_token: $.tirade.resourceful.authToken()}),
        type: 'GET'
      });
      return $.ajax(ajax_options);
    },
    editButton: function(resource_name, id, ajax_options) {
      return $.ui.button({
        icon: 'pencil', text: 'Edit',
        cssclass: 'edit'
      })
      .addClass(resource_name)
      .click(function(event) {
        $.tirade.resourceful.edit(resource_name, id, ajax_options);
        event.preventDefault(); event.stopPropagation();
        return false;
      });
    },
    authToken: function() {
      return $('span.rails-auth-token:last').text();
    }

  });

  // returns just the number (23 of image_23)
  $.fn.resourceId = function() {
    var obj = $(this);
    var id = obj.attr('id');
    var m, first_href, action;
    if ( (id ) && (m = id.match(/(\d+)$/))) {
      return(m[1]);
    } else if (
      (first_href = obj.children('a:first[href!=#]').attr('href')) &&
      (m = first_href.match(/(\d+)$/))) {
      return(m[1]);
    } else if (
      (action = obj.attr('action')) && 
      (action.match(/(\d+)\D*$/))) {
      return(m[1]);
    } else if ( obj[0] && (m = obj[0].className.match(/_(\d+)/))) {
      return(m[1]);
    }
  };

  // Returns image_23
  $.fn.resourceIdentifier = function() {
    var m = $(this).closest('[rel]').attr('rel').match(/([\w_]+_\d+)/);
    if ( m ) { return(m[1]); }
  };

  // Returns { type: 'Image', id: 23 }
  $.fn.typeAndId = function() {
    var match = $(this).closest('[rel]').attr('rel').match(/([\w_]+)_(\d+)/);
    if (match) {
      return({
        type: $.string(match[1]).gsub(/_/,'-').capitalize().camelize().str,
        resource: match[1],
        id: match[2]
      });
    }
  };

  $.fn.resourceURL = function(a) {
    var typeAndId = $(this).typeAndId();
    var action = a ?  a + '_' : '';
    var route = Routing[action + typeAndId.resource + '_path'];
    if (route) {
      return route({id: typeAndId.id, format: 'js', authenticity_token: $.tirade.resourceful.authToken()});
    } else {
      alert("resource not found: " + typeAndId.resource);
    }
  };


  $.fn.resourcefulLink = function(options) {
    var defaults = {
      start: function() { }
    };
    var settings = $.extend(defaults, options);

    return this.each(function(i, element) {
      if (!element.onclick) {
        var obj = $(element);
        obj.click(function(event) {
          event.preventDefault();
          settings.start(event);
          var meth = 'GET';
          var data = '';
          var href = obj.attr('href');
          if (obj.hasClass('create')) {
            meth = 'POST';
          }
          if (obj.hasClass('destroy')) {
            meth = 'DELETE';
            data = 'authenticity_token=' + $.tirade.resourceful.authToken();
            if (!confirm("Really delete?")) { 
              event.stopped = true; // bah.. we dont want other click handlers on this element to fire..
              event.stopPropagation();
              return false;
            }
          }
          var ajaxopts = $.extend(options, {
            url: obj.attr('href'),
            type: meth, data: data
          });
          $.ajax(ajaxopts);
        });
      }
    });
  };


  
  $.fn.fieldFor = function(name) {
    return $(this).find('di.' + name).find(':input');
  };


  $.fn.enableField = function(name) {
    $(this).find('.' + name).show();
    return $(this).fieldFor(name).show().enable();
  };
  $.fn.disableField = function(name) {
    return $(this).fieldFor(name).disable();
  };

  $.fn.listOfItems = function() {
    return $(this).each( function() {
      $('li', this).livequery( function() { $(this).itemInList(); } );
      $(this)
        .unbind('dblclick').dblclick(function(e) { $(e.target).find('a.show,a.index').filter(':first').click(); });
    });
  };

  $.fn.itemInList = function() {
    return $(this).each(function() {
      $(this)
        .addClass('ui-widget-content ui-corner-all ui-state-default')
        .filter(':last-child').addClass('last').end()
        .filter(':has(a.show,a.index)')
          .css('cursor', 'pointer')
          .hover( function() { $(this).addClass('ui-state-hover'); }, function() { $(this).removeClass('ui-state-hover'); })
        .end();
    });
  };
  $.expr[':'].resource = function(obj, index, meta, stack) {
    var match = meta[3].match(/^(\w+)\/(\w+)$/);
    if ( match ) {
      return ($(obj).data('controller') == match[1] && $(obj).data('action') == match[2]);
    } else {
      return false;
    }
  };
})(jQuery);
