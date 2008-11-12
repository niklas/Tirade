/*
 * FormWatch 0.1 Niklas Hofer, ripped of
 *	TypeWatch 2.0 - Original by Denny Ferrassoli / Refactored by Charles Christolini
 *
 *	Examples/Docs: www.dennydotnet.com
 *	
 *  Copyright(c) 2007 Denny Ferrassoli - DennyDotNet.com
 *  Coprright(c) 2008 Charles Christolini - BinaryPie.com
 *  
 *  Dual licensed under the MIT and GPL licenses:
 *  http://www.opensource.org/licenses/mit-license.php
 *  http://www.gnu.org/licenses/gpl.html
 *
 *  looks if the serialized String of a Form changes
 *
 *  Dependencies: jquery.form
*/

(function(jQuery) {
	jQuery.fn.formWatch = function(o){
		// Options
		var options = jQuery.extend({
			wait : 750,
			callback : function() { }
		}, o);
			
		function checkElement(timer, override) {
			var elTxt = jQuery(timer.el).formSerialize();
		
			// Fire if text > options.captureLength AND text != saved txt OR if override AND text > options.captureLength
			if (elTxt.toUpperCase() != timer.text) {
				timer.text = elTxt.toUpperCase();
				timer.cb(elTxt);
			}
		};
		
		function watchElement(elem) {			
			// Must be text or textarea
			if ( jQuery(elem).is('form') ) {

				// Allocate timer element
				var timer = {
					timer : null, 
					text : jQuery(elem).formSerialize(),
					cb : options.callback, 
					el : elem, 
					wait : options.wait
				};

				// Key watcher / clear and reset the timer
				var startWatch = function(evt) {
					var timerWait = timer.wait;
					var overrideBool = false;

               if (jQuery(evt.target).hasClass('search_term')) return;
					
					if (evt.keyCode == 13 && this.type.toUpperCase() == "TEXT") {
						timerWait = 1;
						overrideBool = true;
					}
					
					var timerCallbackFx = function()
					{
						checkElement(timer, overrideBool)
					}
					
					// Clear timer					
					clearTimeout(timer.timer);
					timer.timer = setTimeout(timerCallbackFx, timerWait);				
										
				};
				
				jQuery(elem).keydown(startWatch);
				jQuery(elem).mouseup(startWatch);
			}
		};
		
		// Watch Each Element
		return this.each(function(index){
			watchElement(this);
		});
		
	};

})(jQuery);
