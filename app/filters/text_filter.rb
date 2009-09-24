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
    if text.blank?
      text
    else
      textilize(text)
    end
  end

  def textilize(text)
    RedCloth.new(text).to_html
  end

  # match a [thing:with]{comment}
  def brekkify(text)
    in_brackets = '[^\]]'
    in_braces = '[^\}]'
    text.gsub! /\[(#{in_brackets}+?):(#{in_brackets}+?)\](?:\{(#{in_braces}*?)\})?/im do |ctag|
      name = $1
      id_or_slug = $2
      id = id_or_slug.to_i
      comment = $3

      case name
      when 'image'
        if image = id > 0 ? Image.find_by_id(id) : Image.find_by_slug(id_or_slug)
          %Q[<img src="#{image.url}" alt="#{image.title}"/>]
        end
      else
        '%%% unknown %%%'
      end
    end
  end
end
