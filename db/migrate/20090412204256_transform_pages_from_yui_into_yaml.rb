class TransformPagesFromYuiIntoYaml < ActiveRecord::Migration
  def self.up
    Page.transaction do
      Page.update_all %q~width='750px'~, :yui => 'doc'
      Page.update_all %q~width='950px'~, :yui => 'doc2'
      Page.update_all %q~width='auto'~, :yui => 'doc3'
      Page.update_all %q~width='974px'~, :yui => 'doc4'
    end
  end

  def self.down
    Page.transaction do
      Page.update_all %q~yui='doc'~, :width => '750px'
      Page.update_all %q~yui='doc2'~, :width => '950px'
      Page.update_all %q~yui='doc3'~, :width => 'auto'
      Page.update_all %q~yui='doc4'~, :width => '974px'
    end
  end
end
