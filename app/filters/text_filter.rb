require 'redcloth'
module TextFilter
  def contrabassize(text, vowel='a')
    text.
      gsub(/[aeiou]/, vowel).
      gsub(/[AEIOU]/, vowel.upcase)
  end

  def price(val)
    if val.to_f == 0.0
      'free'
    else
      "&euro; #{sprintf('%.2f', val)}"
    end
  end

  def markup(text)
    RedCloth.new(text).to_html
  end
end
