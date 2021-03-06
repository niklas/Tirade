module RJSSpecHelper

  class ReplaceElement
    attr_reader :select_string, :context
    attr_reader :generated_rjs, :unescaped_rjs
    attr_reader :generated_html, :unescaped_html

    def initialize(select_string)
      @select_string = select_string
    end

    def matches?(generated_rjs, &block)
      @generated_rjs = generated_rjs
      @unescaped_rjs = unescape_rjs(generated_rjs)
      s = select_string
      if unescaped_rjs =~ %r~\$\("#{s}"\).replaceWith\("(.*)"\);~sm
        @generated_html = $1
        @unescaped_html = $1
        yield(unescaped_html) if block_given?
        true
      end
    end

    def description
      "should replace #{select_string}"
    end

    def failure_message
      "should replace element #{select_string} with #{@html_args.inspect}, but did not."
    end

    def negative_failure_message
      "should not replace element #{select_string} with #{@html_args.inspect}, but did."
    end
  end

  def replace_element(expected)
    ReplaceElement.new(expected)
  end


  class HelperRJSPageProxy
    def initialize(context)
      @context = context
      @context.class_eval do # patch the context so that the JavaScriptGenerator uses our helper
        define_method :helpers do
          subject
        end
      end
    end

    def method_missing(method, *arguments)
      block = Proc.new { |page|  @lines = []; page.send(method, *arguments) }
      ActionView::Helpers::PrototypeHelper::JavaScriptGenerator.new(@context, &block).to_s
    end
  end

  def rjs_for
    HelperRJSPageProxy.new(self)
  end

end

