module CssSpecHelper
  class CssMatchesRegexp
    def initialize(*classes)
      @css_classes = classes 
    end
    def matches?(generated_css)
      @generated_css = generated_css
      generated_css =~ regexp
    end
    def clean_classes
      @css_classes.join('.')
    end
  end
  class HideTag < CssMatchesRegexp
    def regexp
      %r~#{tag}\.#{clean_classes}\s+\{\s+display:\s*none\s*;\s*\}~m
    end
    def tag
      "tag"
    end
    def failure_message
      "Did not hide #{tag}.#{clean_classes}, got CSS:\n#{@generated_css}"
    end
    def negative_failure_message
      "Should not hide #{tag}.#{clean_classes}, but it did. got CSS:\n#{@generated_css}"
    end
  end

  class HideForm < HideTag
    def tag
      'form'
    end
  end
  class HideLink < HideTag
    def tag
      'a'
    end
  end

  class ShowTag < CssMatchesRegexp
    def regexp
      prefix = @prefix.blank? ? '' : Regexp.escape(@prefix)
      %r~#{prefix}\s+#{tag}\.#{clean_classes}\s+\{\s+display:\s*#{notnone}\s*;\s*\}~m
    end
    def notnone
      "(?:block|inline)"
    end
    def failure_message
      "Did not show #{@prefix} #{tag}.#{clean_classes}, got CSS:\n#{@generated_css}\nRegexp: #{regexp.inspect}"
    end
    def negative_failure_message
      "Should not show #{@prefix} #{tag}.#{clean_classes}, but it did. got CSS:\n#{@generated_css}\nRegexp: #{regexp}"
    end
    def for(prefix)
      @prefix = prefix
      self
    end
  end

  class ShowForm < ShowTag
    def tag
      'form'
    end
    def notnone
      "block"
    end
  end

  class ShowLink < ShowTag
    def tag
      'a'
    end
    def notnone
      "inline"
    end
  end

  def hide_form(*with_classes)
    HideForm.new(*with_classes)
  end
  def hide_link(*with_classes)
    HideLink.new(*with_classes)
  end
  def show_form(*with_classes)
    ShowForm.new(*with_classes)
  end
  def show_link(*with_classes)
    ShowLink.new(*with_classes)
  end
end
