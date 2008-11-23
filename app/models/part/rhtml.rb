class Part < ActiveRecord::Base
  def rhtml(reload=false)
    @rhtml = nil if reload
    @rhtml ||= File.read(existing_fullpath)
  rescue Exception => e
    ''
  end

  def rhtml=(new_rhtml)
    @rhtml = new_rhtml
  end
  def validate
    validate_rhtml
  end

  def validate_rhtml
    begin
      if errors.on(:filename)
        errors.add(:rhtml, 'Will check RHTML only if filename is valid')
        return
      end
      @html = self.render
      validate_html
    rescue SecurityError => e
      errors.add(:rhtml, 'does something illegal: ' + e.message)
    rescue Exception => e
      errors.add(:rhtml, "is not renderable: (#{filename})" + ERB::Util::html_escape(e.message))
    end
  end

  def validate_html
    return if @html.blank?
    parser = XML::Parser.new
    parser.string = "<div>#{@html}</div>"
    msgs = []
    XML::Parser.register_error_handler lambda { |msg| msgs << msg }
    begin
      parser.parse
    rescue Exception => e
      errors.add(:rhtml, '<pre>' + msgs.collect{|c| c.gsub('<', '&lt;') }.join + '</pre>')
    end
  end


end

