$.extend({
	param: function( a, nest_in ) {
		var s = [ ];
		// check for nest
		if (typeof nest_in == 'undefined') nest_in = false;
		
		function nested(key) {
			if (nest_in)
				return nest_in + '[' + key + ']';
			else
				return key;
		}
		function add( key, value ){
			key = nested(key)
			s[ s.length ] = encodeURIComponent(key) + '=' + encodeURIComponent(value);
		};
		// If an array was passed in, assume that it is an array
		// of form elements
		if ( jQuery.isArray(a) || a.jquery )
			// Serialize the form elements
			jQuery.each( a, function(){
				add( this.name, this.value );
			});

		// Otherwise, assume that it's an object of key/value pairs
		else
			// Serialize the key/values
			for ( var j in a )
				// If the value is an array then the key names need to be repeated
				if ( jQuery.isArray(a[j]) )
					jQuery.each( a[j], function(){
						add( j, this );
					});
				else if (a[j].constructor == Object)
					s.push($.param(a[j], nested(j)));
				else
					add( j, jQuery.isFunction(a[j]) ? a[j]() : a[j] );

		// Return the resulting serialization
		return s.join("&").replace(/%20/g, "+");
	}
});
