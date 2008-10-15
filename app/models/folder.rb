class Folder < Content
  def self.root
    find_by_parent_id nil
  end
  def self.sample
    new(
      :title => 'Example Folder',
      :description => "You won't find anything in this Folder"
    )
  end
end
