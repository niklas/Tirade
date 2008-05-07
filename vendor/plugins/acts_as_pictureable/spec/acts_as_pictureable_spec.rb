require File.dirname(__FILE__) + '/spec_helper'

class Person < ActiveRecord::Base
  acts_as_pictureable
end

describe 'ActsAsPictureable' do
  before(:each) do
    @person = Person.new
  end
  
  it "should respond to picture" do
    @person.should respond_to :picture
  end
end
