module UtilityHelper
  # Makes sure that the given class is in the options which are used for
  # tag helpers like content_tag, link_to etc.
  def add_class_to_html_options(options,name)
    return {} if options.nil?
    if name.is_a?(Array)
      name.flatten.each { |n| add_class_to_html_options(options,n)}
    else
      if options.has_key? :class
        return if name =~ /^odd|even$/ && options[:class] =~ /odd|even/
        options[:class] += " #{name}" unless options[:class] =~ /\b#{name}\b/
      else
        options[:class] = name.to_s
      end
    end
    options
  end

  def add_metadata_to_html_options(options, data)
    options[:data] = data.to_json
  end

end
