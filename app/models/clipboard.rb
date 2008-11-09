class Clipboard
  Field = :clipboard_items

  def initialize(session)
    @session = session
    @items = @session[Field] || []
  end

  def items_by_type
    @items.group_by {|i| split(i).first }.sort.each do |class_name, items|
      objs = objects_for class_name, items.sort
      yield class_name, objs
    end
  end

  def << item
    if obj = object_for(item)
      @items << join(obj)
      @items.uniq!
      save
    end
  end

  def delete item
    @items.delete item
    save
  end
  
  private
  def save
    @session[Field] = @items
  end
  def split item
    if item =~ /^([a-z_]+)_(\d+)$/i
      return [$1,$2.to_i]
    else
      return
    end
  end

  def join obj
    %Q~#{obj.class.to_s.underscore}_#{obj.id}~
  end

  def object_for item
    class_name, id = split(item)
    if class_name && id && valid_class?(class_name)
      klass = class_name.camelize.constantize
      return klass.find_by_id(id)
    end
  end

  def objects_for class_name, items
    if valid_class? class_name
      klass = class_name.camelize.constantize
      ids = items.collect {|i| split(i).last }
      return klass.find_all_by_id(ids)
    end
  end

  # TODO check if type is valid
  def valid_class? class_name
    true
  end
end
