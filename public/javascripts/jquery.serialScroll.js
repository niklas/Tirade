/**
 * jQuery.SerialScroll - Animated scrolling of series
 * Copyright (c) 2007-2008 Ariel Flesler - aflesler(at)gmail(dot)com | http://flesler.blogspot.com
 * Dual licensed under MIT and GPL.
 * Date: 8/3/2008
 * @author Ariel Flesler
 * @version 1.1.2
 *
 * http://flesler.blogspot.com/2008/02/jqueryserialscroll.html
 */
;(function($){var a='serialScroll',b='.'+a,c='bind',u=$[a]=function(b){$.scrollTo.window()[a](b)};u.defaults={duration:1000,axis:'x',event:'click',start:0,step:1,lock:1,cycle:1};$.fn[a]=function(q){q=$.extend({},u.defaults,q);var r=q.event,s=q.step,t=q.duration/s;return this.each(function(){var h=$(this),j=q.lazy?q.items:$(q.items,h),k=q.start,l;if(q.force)n.call(this,{},k);$(q.prev||[])[c](r,-s,m);$(q.next||[])[c](r,s,m);h[c]('prev'+b,-s,m)[c]('next'+b,s,m)[c]('goto'+b,n)[c]('start'+b,function(e,i){if(!q.interval){q.interval=i||1000;p();o()}})[c]('stop'+b,function(){p();q.interval=0});if(!q.lazy&&q.jump)j[c](r,function(e){e.data=j.index(this);n(e,this)});function m(e){e.data+=k;n(e,this)};function n(e,a){if(typeof a=='number'){e.data=a;a=this}var b=e.data,c,d=e.type,f=$(j,h),g=f.length;if(d)e.preventDefault();b%=g;if(b<0)b+=g;c=f[b];if(q.interval){p();l=setTimeout(o,q.interval)}if(isNaN(b)||d&&k==b||q.lock&&h.is(':animated')||!q.cycle&&!f[e.data]||d&&q.onBefore&&q.onBefore.call(a,e,c,h,f,b)===!1)return;if(q.stop)h.queue('fx',[]).stop();q.duration=Math.abs(t*(k-b));h.scrollTo(c,q);k=b};function o(){h.trigger('next'+b)};function p(){clearTimeout(l)}})}})(jQuery);