/* application specific code here */
(function($){
  $(document).ready(function() {


    var $locale_switcher = $('<ul class="locale_switcher" />');
    $('head link.alternate_locale').each(function (i, link) {
      var $link = $(link);
      $('<a />')
        .attr('href', $link.attr('href'))
        .attr('title', $link.attr('lang'))
        .addClass( window.location.pathname == $link.attr('href') ? 'active' : null )
        .text( $link.attr('lang') )
        .appendTo( $locale_switcher )
        .wrap('<li></li>');
    });
    $locale_switcher.appendTo('body > div.page_margins > div.page:first');


  });
})(jQuery);
