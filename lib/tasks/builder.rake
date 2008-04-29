namespace :tirade do
  namespace :build do
    desc "Build a demo Website"
    task :demo => [:environment] do
      url = ENV['URL'] || ENV['url']
      raise "no url given. please append url='where/to/put'" if url.nil?

      title = ENV['TITLE'] || ENV['title']
      raise "no title given. please append title='Demo'" if title.nil?

      Page.transaction do
        Part.recognize_new_files
        base = if url.blank?
                 Page.root || Page.create!(:title => 'Public Root')
               else 
                 Page.find_by_url(url)
               end
        raise "target Page not found: #{url}" if base.nil?

        page = Page.create!(:title => title)
        page.move_to_child_of base

        c1 = Content.create!(:title => 'Hello World', :body => "Welcome to *Tirade*.\n\nThis is just a Demo text.")
        c2 = Content.create!(:title => 'About', :body => "All this Content was created by +rake tirade:build:demo+.")
        c3 = Content.create!(:title => 'WTF', :body => "I do not know what else to say to you. What do you want to see?")
        c4 = Content.create!(:title => 'Ohai', :body => "I made you a Demo.\n\nBut I eated it.\n\nKTHXBAi")

        layout = Grid.new_by_yui('yui-ge')
        layout.save!
        left_column = layout.children.first
        right_column = layout.children.last
        raise 'no left column' unless left_column
        raise 'no right column' unless right_column

        page.layout = layout
        page.save

        part = Part.find_by_filename('simple_preview')
        raise "could not find Part: simple_preview" unless part

        page.renderings.create!(
          :content => c1,
          :grid => left_column,
          :part => part
        )
        page.renderings.create!(
          :content => c2,
          :grid => left_column,
          :part => part
        )
        page.renderings.create!(
          :content => c3,
          :grid => left_column,
          :part => part
        )
        page.renderings.create!(
          :content => c4,
          :grid => right_column,
          :part => part
        )
        Grid.rebuild!
      end
    end
  end
end
