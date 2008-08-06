# database_steps.rb
steps_for(:database) do
   
  Given "some sample content" do
    self.class.fixtures :all   
  end 
    
  Given "no existing $resource_class" do |resource_class|
    klass = resource_class.classify.constantize
    klass.destroy_all 
    klass.count.should eql(0)   
  end

  Given "no $resource_class named '$name' exists" do |resource_class, name|
    klass = resource_class.classify.constantize
    klass.destroy_all(:name => name)
    klass.find_by_name(name).should be_nil
  end

end