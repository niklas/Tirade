[1mdiff --git a/public/javascripts/jquery.layout.js b/public/javascripts/jquery.layout.js[m
[1mindex 893aa81..83d8ea2 100644[m
[1m--- a/public/javascripts/jquery.layout.js[m
[1m+++ b/public/javascripts/jquery.layout.js[m
[36m@@ -377,7 +377,7 @@ $(function() {[m
       return([[m
         $.ui.button({[m
           icon: 'circle-plus', text: 'add rendering', [m
[31m-          class: 'new rendering with_toolbox',[m
[32m+[m[32m          class: 'new rendering with_toolbox tiled',[m
           href: Routing.new_rendering_url({[m
             'rendering[grid_id]': grid.resourceId(),[m
             'rendering[page_id]': $.tirade.currentPageId()[m
[1mdiff --git a/public/javascripts/jquery.toolbox.js b/public/javascripts/jquery.toolbox.js[m
[1mindex 33c1c14..9491e56 100644[m
[1m--- a/public/javascripts/jquery.toolbox.js[m
[1m+++ b/public/javascripts/jquery.toolbox.js[m
[36m@@ -1,6 +1,6 @@[m
 [m
 var Toolbox = {[m
[31m-  findOrCreate: function() {[m
[32m+[m[32m  findOrCreate: function(options) {[m
     if ( this.element().length == 0 ) {[m
       Toolbox.minHeight = 400;[m
       $('body').appendDom(Toolbox.Templates.toolbox);[m
[36m@@ -28,6 +28,14 @@ var Toolbox = {[m
       this.element().show();[m
     };[m
     this.setSizes();[m
[32m+[m[32m    switch (options.mode) {[m
[32m+[m[32m      case 'tiled':[m[41m [m
[32m+[m[32m        this.tile();[m
[32m+[m[32m        break;[m
[32m+[m[32m      case 'maximized':[m
[32m+[m[32m        this.maximize();[m
[32m+[m[32m        break;[m
[32m+[m[32m    }[m
     return this.element();[m
   },[m
   setup: function() {[m
[36m@@ -627,21 +635,23 @@ jQuery.fn.refresh = function() {[m
 [m
 jQuery.fn.useToolbox = function(options) {[m
   var defaults = {[m
[32m+[m[32m    mode: 'normal',[m
     start: function() {}[m
   };[m
[31m-  var options = $.extend(defaults, options);[m
[31m-  if (options.icon) { $(this).uiIcon(icon); }[m
[31m-  if ( !$(this).hasClass("without_toolbox") ) {[m
[31m-    return $(this).resourcefulLink({[m
[32m+[m[32m  return this.each(function() {[m
[32m+[m[32m    var options = $.extend(defaults, options);[m
[32m+[m[32m    if (options.icon) { $(this).uiIcon(icon); }[m
[32m+[m[32m    if ( $(this).hasClass('without_toolbox') ) return; /* next ? */[m
[32m+[m[32m    if ( $(this).hasClass('tiled') ) options.mode = 'tiled';[m
[32m+[m[32m    if ( $(this).hasClass('maximized') ) options.mode = 'maximized';[m
[32m+[m[32m    $(this).resourcefulLink({[m
       start: function(event) {[m
         Toolbox.findOrCreate(options);[m
         Toolbox.beBusy('Loading');[m
         options.start(event);[m
       }[m
     })[m
[31m-  } else {[m
[31m-    return $(this);[m
[31m-  }[m
[32m+[m[32m  });[m
 };[m
 [m
 jQuery.fn.uiIcon = function(icon) {[m
