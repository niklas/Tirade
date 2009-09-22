require File.dirname(__FILE__) + '/../spec_helper'

describe ContentFilter, :type => :helper do

  before( :each ) do
    @filter = Object.new
    @filter.extend ContentFilter
  end

  describe "link" do

    def be_clickable
      have_tag('a[href]', /\w+/)
    end
    def point_to(url)
      have_tag('a[href=?]', url)
    end

    def document
      @document ||= Factory :document, :slug => 'document-slug', :title => 'Just a Document'
    end

    describe "to a Document" do
      subject do
        @filter.link(document)
      end
      it { be_clickable }
      it { point_to(document.slug)  }
      it { have_text(document.title) }
    end

    describe "from a Document to a Title" do
      subject do
        @filter.link(document, 'Special Title')
      end
      it { be_clickable }
      it { point_to(document.slug)  }
      it { have_text('Special Title') }
    end

    describe "from text 'Look Here' to '/an/url'" do
      subject do
        @filter.link('/and/url', 'Look Here')
      end

      it { be_clickable }
      it { point_to('/an/url')  }
      it { have_text('Look Here') }
    end
    
  end
  
end

