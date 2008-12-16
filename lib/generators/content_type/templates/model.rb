class <%= class_name%> < ActiveRecord::Base
  acts_as_content :liquid => [<%= attributes.collect {|a| ":#{a.name}"}. join(', ')%>]
  attr_accessible <%= attributes.collect {|a| ":#{a.name}"}. join(', ')%>
end

