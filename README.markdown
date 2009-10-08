## Introduction

A smart person once told me that every programmer soon or later comes to a
point where (and when) he writes his own Content Management System.

This is my turn.

## Idea

Most of the CMSs out there distinguish between a public frontend for the
visitors (aka "your site") and a backend to manage ... yeah: your site.

My problem with this is: When you are in the process of building your site the
first time or modifying it or its components later, you still have to switch
between these both views. You don't want to save, publish, switch, gnarl,
switch back, edit again... You want to know how your nicely written
essay looks to your visitors. 

Tirade tries to accomplish that by presenting you the whole backend on your
front page, but without interfering with the layout or design. This is where
the Toolbox comes in. It hovers over you page and enables you to see the
results of your actions instantly and even let you interact with your site.

## Features

* free hovering Toolbox with heavy AJAX support
* build up your site by dragging content to your site
* editing any content will preview it on the currently shown page
* easy create your own custom content types
* translations for every content type
* define your boxed-based layouts in the browser
* inherit your layouts through all sub pages
* ...

## Stability

Tirade is all still another experiment of mine. There -may- will be quirks,
crashes or frequent uglyness. I appreciate your help by sending me bug
reports, creating tickets, forking it or just by talking to me.

I try to test everything I can (mostly with rSpec), but the whole Javascript
part is still a shoot from the hips..

## Thanks

Tirade is build onto the great [Ruby on Rails](http://rubyonrails.org)
Framework, [jQuery](http://jquery.com) and [YAML CSS](http://www.yaml.de/).
Without these I would still parse query strings, getElementsByID and wonder
about proper CSS-based layouts.

I use several plugins, extentions and hacks I found across the interwebs - a list of them is a big TODO.

## Fin

Try it out and tell me about it.

