(function($){
  // returns just the number (23 of image_23)
  $.fn.resourceId = function() {
    var obj = $(this);
    if ( (id = obj.attr('id')) && (m = id.match(/(\d+)$/))) {
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
      return(m[1])
    }
  };

  // Returns image_23
  $.fn.resourceIdentifier = function() {
    if ( m = $(this)[0].className.match(/([\w_]+_\d+)/)) {
      return(m[1])
    }
  };

  // Returns { type: 'Image', id: 23 }
  $.fn.typeAndId = function() {
    if (match = $(this)[0].className.match(/([\w_]+)_(\d+)/)) {
      return({
        type: $.string(match[1]).gsub(/_/,'-').capitalize().camelize().str,
        resource: match[1],
        id: match[2]
      });
    }
  };

  $.fn.showUrl = function() {
    var typeAndId = $(this).typeAndId();
    return Routing[typeAndId.resource + '_path']({id: typeAndId.id})
  };


  $.fn.resourcefulLink = function(options) {
    var defaults = {
      start: function() { console.debug("no callback") }
    };
    var options = $.extend(defaults, options);

    return this.each(function(i, element) {
      if (!element.onclick) {
        var obj = $(element);
        obj.click(function(event) {
          event.preventDefault();
          options.start(event);
          meth = 'GET';
          data = '';
          if (obj.hasClass('create'))
            meth = 'POST';
          if (obj.hasClass('destroy')) {
            meth = 'DELETE';
            if (!confirm("Really delete?")) return false;
          };
          $.ajax({
            url: obj.attr('href'),
            type: meth, data: data
          });
        })
      }
    });
  };


  $.fn.addRESTLinks = function(resource, options) {
    var defaults = {
      for: null,
      authToken: resource.find('span.rails-auth-token').text() || 'AuthTokenNotFoundIn-addRestLinks',
      url: null,
      wrap: 'li',
      class: ''
    };
    var options = $.extend(defaults, options);

    if (!options.url) options.url = resource.attr('href');


    if ( (m = options.url.match(/([^\/]+)s\/([^\/]+)/)) && m[1] != 'new') { // has id/slug after plural
      options.class += ' ' + m[1];
      var actions = [
        { name: 'Edit', class: 'edit', url: options.url + '/edit' },
        { name: 'Delete', class: 'destroy' }
      ];
    }
    else if (m = options.url.match(/([^\/]+)s$/)) { // end with plural
      options.class += ' ' + m[1];
      var actions = [
        { name: 'Create', class: 'new', url: options.url + '/new' }
      ];
    }
    else return this;

    return this.each(function() {
      obj = $(this);
      $.each(actions, function(i,action) {
        if ( !obj.find('a').hasClass(action.class) ) {
          url = (action.url || options.url) + '?authenticity_token='+options.authToken;
          obj.appendDom([{
            tagName: options.wrap, childNodes: [{ tagName: 'a', href: url, class: action.class, innerHTML: action.name }]
          }]);
        }
      });
    });
  };

  
  $.fn.fieldFor = function(name) {
    return $(this).find('di.' + name).find(':input')
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
      $('li', this).livequery( function() { $(this).itemInList() } );
      $(this)
        .unbind('dblclick').dblclick(function(e) { $(e.target).find('a.show,a.index').filter(':first').click() });
    });
  };

  $.fn.itemInList = function() {
    return $(this).each(function() {
      $(this)
        .addClass('ui-widget-content ui-corner-all ui-state-default')
        .filter(':has(a.show,a.index)')
          .css('cursor', 'pointer')
          .hover( function() { $(this).addClass('ui-state-hover')}, function() { $(this).removeClass('ui-state-hover') })
        .end()
    });
  };
})(jQuery);
