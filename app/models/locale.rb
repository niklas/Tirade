class Locale
  def self.activated
    I18n.available_locales - [:root]
  end
end
