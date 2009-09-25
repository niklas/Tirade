require File.dirname(__FILE__) + '/../spec_helper'

describe TextFilter, :type => :helper do

  before( :each ) do
    @filter = Object.new
    @filter.extend TextFilter
  end

  describe "brekkify-ing" do

    def f(text)
      @filter.brekkify(text)
    end

    def have_img_tag_for(image)
      have_tag('img[src=?][alt=?]', image.url, image.title)
    end
    def with_img_tag_for(image)
      with_tag('img[src=?][alt=?]', image.url, image.title)
    end

    describe "[image] tags" do

      before( :each ) do
        @image = mock_model(Image, :url => '/images/23.jpg', :title => 'My Image', :id => 23, :slug => 'my-image')
        Image.stub!(:find_by_id).with("23").and_return(@image)
        Image.stub!(:find_by_id).with(23).and_return(@image)
        Image.stub!(:find_by_slug).with("my-image").and_return(@image)
      end

      it "should find image by id" do
        Image.should_receive(:find_by_id).with(23).and_return(@image)
        f("[image:23]").should have_img_tag_for(@image)
      end

      it "should find image by slug" do
        Image.should_receive(:find_by_slug).with("my-image").and_return(@image)
        f("[image:my-image]").should have_img_tag_for(@image)
      end

      it "should show warning if image not found by id" do
        Image.should_receive(:find_by_slug).with('my-image').and_return(nil)
        f("[image:my-image]").should have_tag('div.warning', /Image not found/)
      end

      it "should show warning if image not found by slug" do
        Image.should_receive(:find_by_id).with(23).and_return(nil)
        f("[image:23]").should have_tag('div.warning', /Image not found/)
      end

      describe "giving {}" do
        it "should show image with its title under it" do
          f("[image:23]{}").should have_tag('div.image') do
            with_img_tag_for(@image)
            with_tag('span.title', @image.title)
          end
        end
      end

      describe "giving {Extra Description}" do
        it "should show image with Extra Description under it" do
          f("[image:23]{Extra Description}").should have_tag('div.image') do
            with_img_tag_for(@image)
            with_tag('span.title', 'Extra Description')
          end
        end
      end

      describe "giving alignment" do
        it "should align the image right" do
          f("[image.right:23]").should have_tag('div.image.right') do
            with_img_tag_for(@image)
          end
        end
        it "should align the image left" do
          f("[image.left:23]").should have_tag('div.image.left') do
            with_img_tag_for(@image)
          end
        end
      end
      
      describe "giving alignment and title" do
        it "should align the image right" do
          f("[image.right:23]{Title}").should have_tag('div.image.right') do
            with_img_tag_for(@image)
            with_tag('span.title', 'Title')
          end
        end
        it "should align the image left" do
          f("[image.left:23]{Title}").should have_tag('div.image.left') do
            with_img_tag_for(@image)
            with_tag('span.title', 'Title')
          end
        end
      end
    end

    
  end

end

