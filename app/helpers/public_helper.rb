module PublicHelper
  def dangling_id
    @dangling_id ||= (@controller.instance_variable_get('@item_id')) || 
      (@controller.params.andand[:path].andand.last.andand =~ /^(\d+)$/ ? $1.to_i : nil)
  end

  def title
    returning '' do |title|
      if @page
        title << @page.title unless @page.title.blank?
      end
      if main = Settings.title || 'Tirade'
        title << " - #{main}"
      end
    end
  end

  def exporting?
    request && !request.headers['Tirade-Exporting'].blank?
  end

  def alternate_locale_link(page, locale)
    tag :link, 
      :type => 'alternate',
      :lang => locale.to_s.downcase,
      :class => 'alternate_locale',
      :href => url_for(:path => page.path, :trailing_slash => !page.path.empty?, :locale => locale),
      :media => 'all'
  end

  def wanted_locales
    if request.headers['Tirade-Locales'].present?
      Locale.activated & request.headers['Tirade-Locales'].split(',').map(&:to_sym)
    else
      Locale.activated
    end
  end
end
