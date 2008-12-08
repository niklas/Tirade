(function($){
  // returns just the number (23 of image_23)
  $.fn.resourceId = function() {
    if (m = $(this).attr('id').match(/(\d+)$/)) {
      return(m[1]);
    } else if (
      (first_href = $(this).children('a:first[@href!=#]').attr('href')) &&
      (m = first_href.match(/(\d+)$/))) {
      return(m[1]);
    } else if (
      (action = $(this).attr('action')) && 
      (action.match(/(\d+)\D*$/))) {
      return(m[1]);
    } else if ( m = $(this)[0].className.match(/_(\d+)/)) {
      return(m[1])
    }
  };

  // Returns image_23
  $.fn.resourceIdentifier = function() {
    if ( m = $(this)[0].className.match(/([a-z_]+_\d+)/)) {
      return(m[1])
    }
  };

  // Returns { type: 'Image', id: 23 }
  $.fn.typeAndId = function() {
    if (match = $(this)[0].className.match(/(.+)_(\d+)/)) {
      return({
        type: $.string(match[1]).gsub(/_/,'-').capitalize().camelize().str,
        id: match[2]
      });
    }
  };


  $.fn.resourcefulLink = function(options) {
    var defaults = {
      start: function() { console.debug("no callback") }
    };
    var options = $.extend(defaults, options);

    return this.each(function(i, element) {
      var obj = $(element);
      obj.click(function(event) {
        event.preventDefault();
        options.start(event);
        meth = 'GET';
        if (obj.hasClass('create')) meth = 'POST';
        if (obj.hasClass('destroy')) {
          meth = 'DELETE';
          if (!confirm("Really delete?")) return false;
        }
        $.ajax({
          url: obj.attr('href'),
          type: meth
        });
      });
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


    if (options.url.match(/([^\/])+s\/\d+$/)) { // ends with id
      options.class += ' ' + m[1];
      var actions = [
        { name: 'Edit', class: 'edit' },
        { name: 'Delete', class: 'destroy' }
      ];
    }
    else if (options.url.match(/([^\/])+s$/)) { // end with plural
      options.class += ' ' + m[1];
      var actions = [
        { name: 'Create', class: 'new' }
      ];
    }
    else return this;

    options.url += '?authenticity_token='+options.authToken;

    return this.each(function() {
      obj = $(this);
      $.each(actions, function(i,action) {
        if ( !obj.find('a').hasClass(action.class) ) {
          obj.appendDom([{
            tagName: options.wrap, childNodes: [{ tagName: 'a', href: options.url, class: action.class, innerHTML: action.name }]
          }]);
        }
      });
    });
  };
})(jQuery);
