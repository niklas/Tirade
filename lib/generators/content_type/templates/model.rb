class <%= class_name%> < ActiveRecord::Base
  acts_as_content :liquid => [<%= attributes.collect {|a| ":#{a.name}"}. join(', ')%>]
  attr_accessible <%= attributes.collect {|a| ":#{a.name}"}. join(', ')%>

  def self.sample
    new(
      <% attributes.each_with_index do |attribute, attribute_index| -%>
        :<%= attribute.name %> => nil<%= attribute_index == attributes.length - 1 ? '' : ','%>
      <% end -%>
    )
  end
end

