class Folder < Content
  def self.sample
    new(
      :title => 'Example Folder',
      :description => "You won't find anything in this Folder"
    )
  end
end
