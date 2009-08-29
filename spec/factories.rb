Factory.define :content do |f|
  f.sequence(:title) { |i| "Content ##{i}"}
  f.body "A lot of Text"
end

Factory.define :document do |f|
  f.sequence(:title) { |i| "Document ##{i}"}
  f.sequence(:slug) { |i| "document-#{i}-slug"}
  f.body "A lot of Text"
end

Factory.define :news_item do |f|
  f.sequence(:title) { |i| "News Item ##{i}"}
  f.sequence(:slug) { |i| "news-item-#{i}-slug"}
  f.body "A lot of Text"
end

Factory.define :page do |f|
  f.sequence(:title) { |i| "Page ##{i}"}
  f.sequence(:url) { |i| "page/auto-#{i}"}
  f.width '500px'
  f.alignment 'center'
  f.association :layout, :factory => :grid
end

Factory.define :grid do |f|
  f.sequence(:title) { |i| "Grid ##{i}"}
  f.float 'l'
  f.width 50
end

Factory.define :part do |f|
  f.sequence(:name) { |i| "Part ##{i}"}
  f.sequence(:filename) { |i| "part_#{i}" }
  f.preferred_types %w(Document)
end

Factory.define :static_part, :parent => :part do |f|
  f.preferred_types %w(none)
end

Factory.define :rendering do |f|
  f.association :part
  f.association :page
  f.association :grid
  f.assignment 'fixed'
  f.content_type 'Document'
  f.scope_definition({})
  f.plural false
end

Factory.define :scoped_rendering, :parent => :rendering do |f|
  f.assignment 'scope'
  f.content_type 'Document'
  f.plural true
end

Factory.define :image do |f|
  f.sequence(:title) { |i| "Image ##{i}"}
  f.sequence(:image_file_name) {|i| "a_nice_image#{i}.jpg" }
  f.image_content_type 'image/jpg'
  f.image_file_size 2342
end
