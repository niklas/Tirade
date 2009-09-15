require File.dirname(__FILE__) + '/../spec_helper'

describe CollectionFrameRenderer do
  before( :each ) do
    stubs_for_helper
    5.times { Factory :document }
    @collection = Document.all
    @r = CollectionFrameRenderer.new(@collection, template)
  end
end

