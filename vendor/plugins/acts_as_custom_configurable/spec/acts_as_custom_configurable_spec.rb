require File.dirname(__FILE__) + '/spec_helper'
describe 'A nice House' do
  before(:each) do
    @house = House.new(:label => 'Mulder Lane 23')
    @house.defined_options = {
      :story_count => [:integer, 1],
      :address => [:string, 'no Address'],
      :inhabited => [:boolean, false]
    }
  end
  it "should be a house" do
    @house.should be_instance_of(House)
  end
  it "should be valid" do
    @house.should be_valid
  end

  it "should respond to #options" do
    @house.should respond_to(:options)
  end

  it "should return options" do
    @house.options.should_not be_nil
  end


  it "should have default story_count" do
    @house.options.story_count.should == 1
  end
  it "should have default address" do
    @house.options.address.should == 'no Address'
  end
  it "should have default inhabited_state" do
    @house.options.inhabited.should be_false
  end
  it "should throw exception if accessing undefined fields?" do
    lambda do
      @house.options.drill_instructor
    end.should raise_error(NoMethodError)
  end

  describe ", set the story_count to 5" do
    before(:each) do
      @house.options.story_count = 5
    end
    it "should have the new story_count" do
      @house.options.story_count.should == 5
    end
    it "should have default address" do
      @house.options.address.should == 'no Address'
    end
    it "should have default inhabited_state" do
      @house.options.inhabited.should be_false
    end
  end

  describe ", set the story_count to 5 and address to 'Clark Avenue'" do
    before(:each) do
      @house.options.story_count = 5
      @house.options.address = 'Clark Avenue'
    end
    it "should have the new story_count" do
      @house.options.story_count.should == 5
    end
    it "should have default address" do
      @house.options.address.should == 'Clark Avenue'
    end
    it "should have default inhabited_state" do
      @house.options.inhabited.should be_false
    end

    describe ", saving and reloading" do
      before(:each) do
        @house.save
        @house = House.find(@house.id)
      end
      it "should have the new story_count" do
        @house.options.story_count.should == 5
      end
      it "should have default address" do
        @house.options.address.should == 'Clark Avenue'
      end
      it "should have default inhabited_state" do
        @house.options.inhabited.should be_false
      end
    end
  end

  describe 'with four rooms' do
    before(:each) do
      lambda do
        @house.save
        @green_room = @house.rooms.create(:label => 'green')
        @purple_room = @house.rooms.create(:label => 'purple')
        @red_room = @house.rooms.create(:label => 'red')
        @blue_room = @house.rooms.create(:label => 'blue')
        @all_rooms = [@green_room, @purple_room, @red_room, @blue_room]
      end.should change(Room, :count).by(4)
    end
    it "should find the four rooms" do
      @house.should have(4).rooms
    end

    describe ". The Green room" do
      it "should know about options" do
        @green_room.should respond_to(:options)
      end
      it "should have options" do
        @green_room.options.should_not be_nil
      end
      it "should have default (house) story_count" do
        @green_room.options.story_count.should == 1
      end
      it "should have default (house) address" do
        @green_room.options.address.should == 'no Address'
      end
      it "should have default (house) inhabited_state" do
        @green_room.options.inhabited.should be_false
      end
    end

    describe ". The Purple room in a 7 Story House" do
      before(:each) do
        @house.options.story_count = 7
        @house.save
      end
      it "should find the new stroy_count in the house" do
        @purple_room.house.options.story_count.should == 7
      end
      it "should have the house's story_count" do
        @purple_room.options.story_count.should == 7
      end
      it "should have default (house) address" do
        @purple_room.options.address.should == 'no Address'
      end
      it "should have default (house) inhabited_state" do
        @purple_room.options.inhabited.should be_false
      end
    end

    describe ". The Red room being inhabited" do
      before(:each) do
        @red_room.options.inhabited = true
      end
      it "should have the house's story_count" do
        @red_room.options.story_count.should == 1
      end
      it "should have default (house) address" do
        @red_room.options.address.should == 'no Address'
      end
      it "should have default (house) inhabited_state" do
        @red_room.options.inhabited.should be_true
      end
    end

    describe ". The Blue room beeing inhabited in space" do
      before(:each) do
        @house.options.story_count = 2342
        @house.options.address = 'Open Space'
        @house.save
        @blue_room.options.inhabited = true
        @blue_room.save
      end
      it "should have the house's story_count" do
        @blue_room.options.story_count.should == 2342
      end
      it "should have default (house) address" do
        @blue_room.options.address.should == 'Open Space'
      end
      it "should have default (house) inhabited_state" do
        @blue_room.options.inhabited.should be_true
      end

      describe ", reloaded" do
        before(:each) do
          @house = House.find(@house.id)
          @blue_room = Room.find(@blue_room.id)
        end
        it "should have the house's story_count" do
          @blue_room.options.story_count.should == 2342
        end
        it "should have default (house) address" do
          @blue_room.options.address.should == 'Open Space'
        end
        it "should have default (house) inhabited_state" do
          @blue_room.options.inhabited.should be_true
        end
      end

    end
    
    describe "updating the house's options with a hash like in params" do
      before(:each) do
        @parms = {
          :story_count => "3",
          :address => 'Your Mums House',
          :inhabited => "1"
        }.with_indifferent_access
        lambda do
          @house.options = @parms
          @house.save
        end.should_not raise_error
      end
      it "should have the new story_count" do
        @house.options.story_count.should == 3
      end
      it "should have the new address" do
        @house.options.address.should == 'Your Mums House'
      end
      it "should have the new inhabited state" do
        @house.options.inhabited.should be_true
      end
      it ", its rooms should have the new story_count" do
        @all_rooms.each do |room|
          room.options.story_count.should == 3
        end
      end
      it ", its rooms should have the new address" do
        @all_rooms.each do |room|
          room.options.address.should == 'Your Mums House'
        end
      end
      it ", its rooms should have the new inhabited state" do
        @all_rooms.each do |room|
          room.options.inhabited.should be_true
        end
      end

      describe "moving the red room to hell" do
        before(:each) do
          @red_room.options.address = 'Hell'
        end
        it "should be there" do
          @red_room.options.address.should == 'Hell'
        end
        it ", the house should stay at its place" do
          @house.options.address.should == 'Your Mums House'
        end

        describe ", bringing it back" do
          before(:each) do
            @red_room.options.address = ""
          end
          it "should be back home" do
            @red_room.options.address.should == 'Your Mums House'
          end
          it ", the house should stay at its place" do
            @house.options.address.should == 'Your Mums House'
          end
        end
      end
    end

    describe "updating the house's options with a sparse hash like in params" do
      before(:each) do
        @parms = {
          :story_count => "3",
          :inhabited => "false"
        }.with_indifferent_access
        lambda do
          @house.options = @parms
          @house.save
        end.should_not raise_error
      end
      it "should have the new story_count" do
        @house.options.story_count.should == 3
      end
      it "should have the old address" do
        @house.options.address.should == 'no Address'
      end
      it "should have the new story_count" do
        @house.options.inhabited.should be_false
      end
      it ", its rooms should have the new inhabited state" do
        @all_rooms.each do |room|
          room.options.story_count.should == 3
        end
      end
      it ", its rooms should have the old address" do
        @all_rooms.each do |room|
          room.options.address.should == 'no Address'
        end
      end
      it ", its rooms should have the new inhabited state" do
        @all_rooms.each do |room|
          room.options.inhabited.should be_false
        end
      end
    end

    describe "editing the red room in a Form spiced up with", ActsAsConfigurable::FormBuilder do
      before(:each) do
        # TODO remove them
        extend ActionView::Helpers::TagHelper
        extend ActionView::Helpers::FormTagHelper
        @builder = ActionView::Helpers::FormBuilder.new(:room, @red_room, self, {}, nil)
        lambda do
          @form = @builder.select_options
        end.should_not raise_error
      end
      it "should not be empty" do
        @form.should_not be_empty
      end

      it "should have a label and field for all the options defined by house" do
        @form.should have_tag('ul#room_options') do
          with_tag('li') do
            with_tag('label')
            with_tag('input#room_options_story_count[name=?][type=text]', 
            'room[options][story_count]')
          end
          with_tag('li') do
            with_tag('label')
            with_tag('input#room_options_address[name=?][type=text]',
            'room[options][address]')
          end
          with_tag('li') do
            with_tag('label')
            with_tag('input#room_options_inhabited[name=?][type=checkbox]', 
            'room[options][inhabited]')
          end
        end
      end
    end

  end

  describe "editing in a Form spiced up with", ActsAsConfigurable::FormBuilder do
    before(:each) do
      # TODO remove them
      extend ActionView::Helpers::TagHelper
      extend ActionView::Helpers::FormTagHelper
      @builder = ActionView::Helpers::FormBuilder.new(:house, @house, self, {}, nil)
      lambda do
        @form = @builder.select_options
      end.should_not raise_error
    end
    it "should not be empty" do
      @form.should_not be_empty
    end

    it "should have a label and field for all the options defined by house" do
      @form.should have_tag('ul#house_options') do
        with_tag('li') do
          with_tag('label')
          with_tag('input#house_options_story_count[name=?][type=text]', 
          'house[options][story_count]')
        end
        with_tag('li') do
          with_tag('label')
          with_tag('input#house_options_address[name=?][type=text]',
          'house[options][address]')
        end
        with_tag('li') do
          with_tag('label')
          with_tag('input#house_options_inhabited[name=?][type=checkbox]', 
          'house[options][inhabited]')
        end
      end
    end
  end
  describe "defining in a Form spiced up with", ActsAsConfigurable::FormBuilder do
    before(:each) do
      # TODO remove them
      extend ActionView::Helpers::TagHelper
      extend ActionView::Helpers::PrototypeHelper
      extend ActionView::Helpers::JavaScriptHelper
      extend ActionView::Helpers::FormTagHelper
      extend ActionView::Helpers::FormOptionsHelper
      @builder = ActionView::Helpers::FormBuilder.new(:house, @house, self, {}, nil)
      lambda do
        @form = @builder.define_options
      end.should_not raise_error
    end
    it "should not be empty" do
      @form.should_not be_empty
    end

    it "should have a all already defined options of house" do
      @form.should have_tag('ul#house_defined_options.define_options') do
        with_tag('li') do
          with_tag('input[name=?][type=text]', 'house[define_options][name][]')
          with_tag('input[name=?][type=text]', 'house[define_options][default][]')
          with_tag('select[name=?]', 'house[define_options][type][]') do
            with_tag('option[value=?]', 'string')
            with_tag('option[value=?]', 'integer')
            with_tag('option[value=?]', 'boolean')
          end
        end
      end
    end
  end

end

describe "Defining opts of a house" do
  before(:each) do
    @house = House.new(:label => 'Skyscraper')
    # defined in alphabetic order, since comparing is easier
    @def_form = {
      :name => %w(nickname public story_count),
      :default => ["Tally", false, 42],
      :type => %w(string boolean integer)
    }.with_indifferent_access
    @def_saved = {
      'story_count' => ['integer', 42],
      'nickname' => ['string', "Tally"],
      'public' => ['boolean', false]
    }
    @options_hash = {
      'story_count' => 42,
      'nickname' => 'Tally',
      'public' => false
    }
  end
  describe "from a Form" do
    before(:each) do
      @house.define_options = @def_form
    end
    it "should have the valid saved definitions" do
      @house.defined_options.should == @def_saved
    end
    it "should have the valid form definitions" do
      @house.define_options.should == @def_form
    end
    it "should be able to export the definitions" do
      @house.defined_options.to_yaml.should_not be_empty
    end
    it "should have the options with default values" do
      @house.options.to_hash_with_defaults.should == @options_hash
    end
  end

  describe "from saved" do
    before(:each) do
      @house.defined_options = @def_saved
    end
    it "should have the valid form definitions" do
      @house.define_options.should  == @def_form
    end
    it "should have the valid saved definitions" do
      @house.defined_options.should == @def_saved
    end
    it "should be able to export the definitions" do
      @house.defined_options.to_yaml.should_not be_empty
    end
  end
end
