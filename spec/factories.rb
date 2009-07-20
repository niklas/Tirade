Factory.define :content do |f|
  f.sequence(:title) { |i| "Content ##{i}"}
  f.body "A lot of Text"
end

Factory.define :document, :parent => :content do |f|
  f.sequence(:title) { |i| "Document ##{i}"}
  f.add_attribute :type, 'Document'
end

Factory.define :page do |f|
  f.sequence(:title) { |i| "Page ##{i}"}
  f.sequence(:url) { |i| "/page/auto/#{i}"}
  f.width '500px'
  f.alignment 'center'
  f.association :layout, :factory => :grid
end

Factory.define :grid do |f|
  f.sequence(:title) { |i| "Grid ##{i}"}
  f.division 'leaf'
end

Factory.define :part do |f|
  f.sequence(:name) { |i| "Part ##{i}"}
  f.sequence(:filename) { |i| "part_#{i}" }
  f.preferred_types %w(Content)
end

Factory.define :rendering do |f|
  f.association :part
  f.association :page
  f.association :grid
  f.assignment 'fixed'
  f.content_type 'Content'
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
