## Introduction

A smart person once told me that every programmer soon or later comes to a
point where (and when) she writes her own Content Management System.

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
results of your actions instantly and even lets you interact with your site.

## Features

What does Tirade has to offer?

* Toolbox hovering over your page, heavy AJAX dependant
* comes with common Content Types build in: Document, Folder, Image, News Folder, Asset
* not enough? simply create your own custom Content Types
* build up your site by dragging and dropping Content
* editing any Content will preview it on the currently shown page (if present)
* define your boxed-based layouts in the browser
* inherit your layouts through all sub pages
* write one Document, show it multiple times in different ways on your site
* drop Contents once, show it on all sub pages, for example a disclaimer
* translations for every Content Type
* a set of HTML snippets to put your Content on your site
* Theme support - you can change the appearance of your site with one click 
* you upload a big Image, Tirade will scale it to any size you want, aspect aware
* ...

## Antifeatures

What is missing in Tirade?

* modification of the design (CSS) in the Toolbox - this should be done by a designer
* some features are hidden, hard to find or complex to use - working on that
* reading minds - you must write Content yourself
* ...

## Stability

Tirade is all still another experiment of mine. There -may- will be quirks,
crashes or frequent uglyness. I'd appreciate any of your help by sending me bug
reports, creating tickets, forking it or just by talking to me.

I try to test everything as I go (primarily with rSpec), but the whole Javascript
part is still a shoot from the hips..

## Thanks

Tirade is build onto the great [Ruby on Rails](http://rubyonrails.org)
Framework, [jQuery](http://jquery.com) and [YAML CSS](http://www.yaml.de/).
Without these I would still parse query strings, getElementsByID and wonder
about proper CSS-based layouts.

I use several plugins, extentions and hacks I found across the interwebs - a list of them is a big TODO.

## Fin

Check it out and give me feedback!

