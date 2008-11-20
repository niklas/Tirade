module ActiveRecord
  class Base
    class << self

      # FIXME Quick-fix http://dev.rubyonrails.org/ticket/10686 until it is released
      def update_all(updates, conditions = nil, options = {})
        sql  = "UPDATE #{table_name} SET #{sanitize_sql_for_assignment(updates)} "
        scope = scope(:find)
        add_conditions!(sql, conditions, scope)
        add_order!(sql, options[:order], nil)
        add_limit!(sql, options, nil)
        connection.update(sql, "#{name} Update")
      end

      def label
        self.to_s
      end

      def name_for_js
        label.underscore
      end

      def without_modification
        transaction do
          yield
          raise Rollback
        end
      end

      # FIXME without_timestamps does not work
      # see http://blog.evanweaver.com/articles/2006/12/26/hacking-activerecords-automatic-timestamps/
      # only works because rails is not thread safe. 
      # but a thread safe version could be written.
      def without_timestamps
        self.record_timestamps = false
        yield
        self.record_timestamps = true
      end
    end
  end
end

class String
  def urlize
    strip.gsub(/[^\w]+/,'-').sub(/-\Z/,'').downcase
  end
  def domify
    strip.gsub(/[^\w]+/,'_').sub(/_\Z/,'').downcase
  end

  def brighter(n=1)
    return self if n <= 0
    brighter(n-1).tr('0123456789abcdef','123456789abcdeff')
  end

  def darker(n=1)
    return self if n <= 0
    darker(n-1).tr('0123456789abcdef','00123456789abcde')
  end
end

class Array
  def skip(num=1)
    self[num..-1]
  end
end

module Sass
  module ThemeSupport
    # Patch the process to set SASS path to the current theme, thus supporting sass stylesheets in themes
    def process(*args)
      if defined?(Sass)
        theme = args.first.parameters[:theme]
        old_sass_options = Sass::Plugin.options
        Sass::Plugin.options.merge!(:template_location  => RAILS_ROOT + "/themes/#{theme}/stylesheets/sass",
                                    :css_location       => RAILS_ROOT + "/themes/#{theme}/stylesheets",
                                    :always_check       => RAILS_ENV != "production",
                                    :always_update      => RAILS_ENV != "production",
                                    :full_exception     => RAILS_ENV != "production")
        # FIXME do not render sass stylesheets on every request
        Sass::Plugin.update_stylesheets
        Sass::Plugin.options.merge!(old_sass_options)
      end
      super
    end
  end
end

ThemeController.send :include, Sass::ThemeSupport
