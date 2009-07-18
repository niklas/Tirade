module ToolboxSpecHelper

  class ActivateDomId
    def initialize(target_dom_id)
      @target_dom_id = target_dom_id
    end
    def matches?(generated_rjs)
      @generated_rjs = generated_rjs
      @unescaped_rjs = unescape_rjs(generated_rjs)
      @unescaped_rjs =~ %r~\$\("#{@target_dom_id}"\)\.addClassName\("active"\)~
    end
    def failure_message
      "did not activate #{@target_dom_id}"
    end
    def negative_failure_message
      "did activate #{@target_dom_id}, but it shouldn't"
    end
  end

  class DeactivateAll
    def initialize
    end
    def matches?(generated_rjs)
      @generated_rjs = generated_rjs
      @unescaped_rjs = unescape_rjs(generated_rjs)
      @unescaped_rjs =~ %r~\$\$\("div.active"\).*value\.removeClassName.*resetBehavior~m
    end
    def failure_message
      "did not deactivate all active divs"
    end
    def negative_failure_message
      "deactivated all active divs, but it shouldn't"
    end
  end

  class PushToolboxFrame
    def initialize(expected='')
      @expected = expected
    end
    def matches?(js)
      @unescaped_rjs = unescape_rjs(js)
      @unescaped_rjs =~ %r~Toolbox.push~
    end
    def failure_message
      "did not push frame into toolbox"
    end
  end


  class UpdateLastToolboxFrame
    def initialize(expected_action = 'show')
      @expected_action = expected_action
    end

    def matches?(js)
      @unescaped_rjs = unescape_rjs(js)
      @unescaped_rjs =~ %r~Toolbox.updateLastFrame~
    end

    def failure_message
      "did not update last frame of toolbox"
    end
  end


  # Unescapes a RJS string.
  def unescape_rjs(rjs_string)
    rjs_string = rjs_string.body if rjs_string.respond_to?(:body)
    # RJS encodes double quotes and line breaks.
    rjs_string.gsub('\"', '"').
    gsub(/\\\//, '/').
    gsub('\n', "\n").
    gsub('\076', '>').
    gsub('\074', '<').
    # RJS encodes non-ascii characters.
    gsub(/\\u([0-9a-zA-Z]{4})/) {|u| [$1.hex].pack('U*')}
  end

  def activate_dom_id(expected)
    ActivateDomId.new(expected)
  end
  def deactivate_all
    DeactivateAll.new
  end
  def set_toolbox_header(expected)
    have_text( %r~"title": "#{expected}"~)
  end

  def pop_frame_and_refresh_last
    have_text( /Toolbox.popAndRefreshLast\(\)/ )
  end

  def push_frame(expected='')
    PushToolboxFrame.new(expected)
  end

  def update_last_frame(*args)
    UpdateLastToolboxFrame.new(*args)
  end

end
