class TransformGridsFromYuiIntoYaml < ActiveRecord::Migration
  def self.up
    Grid.transaction do
      Grid.update_all %q~division='50-50'~, :yui => 'yui-g'
      Grid.update_all %q~division='33-33-33'~, :yui => 'yui-gb'
      Grid.update_all %q~division='66-33'~, :yui => 'yui-gc'
      Grid.update_all %q~division='33-66'~, :yui => 'yui-gd'
      Grid.update_all %q~division='75-25'~, :yui => 'yui-ge'
      Grid.update_all %q~division='25-75'~, :yui => 'yui-gf'
      Grid.update_all %q~division='leaf'~, :yui => 'yui-u'
    end
  end

  def self.down
    Grid.transaction do
      Grid.update_all %q~division='yui-g'~, :division => '50-50'
      Grid.update_all %q~division='yui-gb'~, :division => '33-33-33'
      Grid.update_all %q~division='yui-gc'~, :division => '66-33'
      Grid.update_all %q~division='yui-gd'~, :division => '33-66'
      Grid.update_all %q~division='yui-ge'~, :division => '75-25'
      Grid.update_all %q~division='yui-gf'~, :division => '25-75'
      Grid.update_all %q~division='yui-u'~, :division => 'leaf'
    end
  end
end
