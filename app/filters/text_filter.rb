require 'redcloth'
module TextFilter
  def contrabassize(text, vowel='a')
    text.
      gsub(/[aeiou]/, vowel).
      gsub(/[AEIOU]/, vowel.upcase)
  end

  def markup(text)
    RedCloth.new(text).to_html
  end
end
