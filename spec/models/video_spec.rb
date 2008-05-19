require File.dirname(__FILE__) + '/../spec_helper'

describe Video do
  before(:each) do
    @video = Video.new
  end

  it "should be valid" do
    @video.should be_valid
  end
end

describe "The XML fixture 'flv_videos'" do
  before(:each) do
    @xmlfile = File.join(File.dirname(__FILE__), '../fixtures/flv_videos.xml')
  end

  it "should exist" do
    File.exists?(@xmlfile).should be_true
  end

  describe "reading it" do
    before(:each) do
      @xml = File.read(@xmlfile)
    end

    it "should contain some data" do
      @xml.should_not be_empty
    end


    describe "parsing it" do
      before(:each) do
        @videos = Video.new_from_xml(@xml)
      end

      it "should return something" do
        @videos.should_not be_nil
      end

      it "should have at least two videos in it" do
        @videos.should have_at_least(2).records
      end

      describe ", the first found video" do
        before(:each) do
          @video = @videos.first
        end

        it "should be valid" do
          @video.should be_valid
        end

        it "should have correct id" do
          @video.id.should == 2342556
        end

        it do
          @video.artist_name.should == 'Nancy Sinatra'
        end

        it do
          @video.title.should == "Bang Bang"
        end

        it "should have an url" do
          @video.url.should =~ /2342556/
        end

        it "should have a full url" do
          @video.full_url.should == 'http://example.com/videos/www/xml/flv/flvgen.jhtml?vid=2342556'
        end

        it do
          @video.image_url.should == 'http://example.com/nancy_sinatra_-_bang_bang.jpg'
        end
      end

      describe ", the second found video" do
        before(:each) do
          @video = @videos[1]
        end

        it "should be valid" do
          @video.should be_valid
        end

        it "should have correct id" do
          @video.id.should == 4223556
        end

        it do
          @video.artist_name.should == 'Santa Esmeralda'
        end

        it do
          @video.title.should == "Don't let me be misunderstood"
        end

        it "should have an url" do
          @video.url.should =~ /4223556/
        end

        it "should have a full url" do
          @video.full_url.should == 'http://example.com/videos/www/xml/flv/flvgen.jhtml?vid=4223556'
        end

        it do
          @video.image_url.should == 'http://example.com/santa_esmeralda_-_dont_let_me_be_misunderstood.jpg'
        end
      end
    end

    describe ", importing the videos" do
      before(:each) do
        lambda {
          @created_videos = Video.create_from_xml_unless_exist(@xml)
        }.should change(Video,:count).by(2)
      end

      describe ", reimporting them" do
        before(:each) do
          lambda {
            @re_created_videos = Video.create_from_xml_unless_exist(@xml)
          }.should_not change(Video,:count)
        end

        it "should not create any video" do
          @re_created_videos.should be_empty
        end
      end

    end

  end
end

describe "The Youtube feed" do
  before(:each) do
    @feed = File.join(File.dirname(__FILE__), '../fixtures/top_rated_today.rss')
  end

  it "should exist" do
    File.exists?(@feed).should be_true
  end

  describe ", reading it" do
    before(:each) do
      @rss = File.read(@feed)
    end
    it "should contain some data" do
      @rss.should_not be_empty
    end

    describe ", parsing it" do
      before(:each) do
        @videos = YoutubeVideo.new_from_xml(@rss)
      end
      it "should return something" do
        @videos.should_not be_nil
      end

      it "should have at least two videos in it" do
        @videos.should have_at_least(15).records
      end
      describe ". The first Video" do
        before(:each) do
          @video = @videos.first
        end
        it "should be valid" do
          @video.should be_valid
        end

        it "should have correct id" do
          @video.id.should_not be_nil
        end

        it do
          @video.artist_name.should =~ /bravenewfilms/
        end

        it do
          @video.title.should == "McCain's YouTube Problem Just Became a Nightmare"
        end

        it "should have an url" do
          @video.url.should == 'http://youtube.com/v/GEtZlR3zp4c.swf'
        end
        it "sshould have correct image url "do
          @video.image_url.should == 'http://s4.ytimg.com/vi/GEtZlR3zp4c/default.jpg'
        end

        describe ", saving it" do
          before(:each) do
            lambda do 
              @video.save
            end.should_not raise_error
          end
          it "should have an id" do
            @video.id.should_not be_nil
          end

          it "should have correct id" do
            @video.id.should == 428886364
          end
        end

      end

      describe ". The second Video" do
        before(:each) do
          @video = @videos[1]
        end
        it "should be valid" do
          @video.should be_valid
        end

        it "should have correct id" do
          @video.id.should_not be_nil
        end

        it do
          @video.artist_name.should == 'NeilCicierega'
        end

        it do
          @video.title.should == 'Potter Puppet Pals in "The Vortex"'
        end

        it "should have an url" do
          @video.url.should == 'http://youtube.com/v/Y18LUMkVt2Y.swf'
        end
        it "sshould have correct image url "do
          @video.image_url.should == 'http://s2.ytimg.com/vi/Y18LUMkVt2Y/default.jpg'
        end

        describe ", saving it" do
          before(:each) do
            lambda do 
              @video.save
            end.should_not raise_error
          end
          it "should have an id" do
            @video.id.should_not be_nil
          end

          it "should have correct id" do
            @video.id.should == 996884670
          end
        end

      end
    end
    describe ", importing the videos" do
      before(:each) do
        lambda {
          @created_videos = YoutubeVideo.create_from_xml_unless_exist(@rss)
        }.should change(Video,:count).by(15)
      end

      describe "A YoutubeVideoCollection" do
        before(:each) do
          @collection = YoutubeVideoCollection.new(:title => 'youtube')
        end
        it "should have videos" do
          @collection.should have_at_least(15).videos
        end
        it "should have videos as items" do
          @collection.should have_at_least(15).items
        end

        describe ", subselectiing a video" do
          before(:each) do
            lambda do
              @video = @collection.videos.find(996884670)
            end.should_not raise_error
          end
          it "should be a YoutubeVideo" do
            @video.should be_instance_of(YoutubeVideo)
          end

        end
      end

      describe ", reimporting them" do
        before(:each) do
          lambda {
            @re_created_videos = YoutubeVideo.create_from_xml_unless_exist(@rss)
          }.should_not change(Video,:count)
        end

        it "should not create any video" do
          @re_created_videos.should be_empty
        end
      end

    end
  end
end
