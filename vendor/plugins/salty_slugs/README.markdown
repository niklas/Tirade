## SaltySlugs

 Abstraction of word-based slugs for URLs, w/ or w/o leading numeric IDs.
 
## Installation

* Using Rails 2.1+

<pre>
./script/plugin install git://github.com/norbauer/salty_slugs.git
</pre>

## Instructions

* SaltySlugs defaults to `title` as the `source_column`, `slug` as the `slug_column`, and prepends the model ID. Upon creating/updating a record, the plugin will sluggify the `source_column` when the `slug_column` is empty, otherwise it will sluggify the `slug_column` _unless_ the `slug_sync` option is set to true (defaults to false).

<pre> 
class Post < ActiveRecord::Base
   has_slug
end
 
post = Post.create(:title => "Do Not Mix Slugs and Salt!")
@post.to_param
=> '23-do-not-mix-slugs-and-salt'
</pre>

* You can also overwrite the defaults

<pre>
class Product < ActiveRecord::Base
   has_slug :source_column => :name, :slug_column => :permalink, :prepend_id => false
end
 
@product = Product.create(:name => "Salt and Pepper Shaker")
@product.to_param
=> 'salt-and-pepper-shaker'
</pre>
 
* Use the `slugged_find` class method in your controllers, smart enough to modify the search conditions if prepending ID is found or not. `slugged_find` is capable of accepting standard `ActiveRecord::Base#find` options as a second parameter. If no records are found, `ActiveRecord::RecordNotFound` is raised to match behavior of `ActiveRecord::Base#find`.

<pre>
class PostsController < ApplicationController

   def show
     @post = Post.slugged_find(params[:id])
     # or optionally with an eager-load
     @post_with_author = Post.slugged_find(params[:id], :include => :author)
   # catch exceptions if post is not found
   rescue ActiveRecord::RecordNotFound
     flash[:error] = "Post not found"
     redirect_to :action => :index
   end
   
end
</pre>

* If the `sync_slug` option is set to true, the `source_column` will _always_ be sluggified upon updating the record.  This means that the slug will not be able to be manually edited, but will always be synchronized to the `source_column`.

## TODO

* Add a word/regexp blacklist, so that they are sliced out of a string when sluggified (for example to remove .com, .net, etc)

---
Copyright (c) 2008 Norbauer Inc, released under the MIT license
<br/>Written by Jonathan Dance and Jose Fernandez
