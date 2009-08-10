module GenericSpecHelper
  class IncludeAny
    def initialize(expected)
      @expected = expected
      @collection = []
    end
    def matches?(collection)
      @collection = collection
      collection.any? {|e| e =~ @expected }
    end
    def description
      "should include any element matching #{@expected}"
    end
    def failure_message
      "did not include any element matching #{@expected}"
    end
    def negative_failure_message
      "includes at least one element matching #{@expected} (#{matching_element.inspect}), but shouldn't"
    end
    def matching_element
      @collection.select {|e| e =~ @expected }
    end
  end
  def include_any(expected)
    IncludeAny.new(expected)
  end
end
    
