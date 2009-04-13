unless ActiveRecord::Base.respond_to? :named_scope
  gem 'has_finder'
  require 'has_finder'
end
require 'parsing'
require 'has_fulltext_search'

ActiveRecord::Base.class_eval { include HasFulltextSearch }
