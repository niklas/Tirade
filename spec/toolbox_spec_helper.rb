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
  # Unescapes a RJS string.
  def unescape_rjs(rjs_string)
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

end
