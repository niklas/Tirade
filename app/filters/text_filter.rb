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

  # match a [thing:with]{title}
  def brekkify(text)
    in_brackets = '[^\]]'
    in_braces = '[^\}]'
    text.gsub! /\[(#{in_brackets}+?):(#{in_brackets}+?)\](?:\{(#{in_braces}*?)\})?/im do |ctag|
      name = $1.strip
      id_or_slug = $2
      id = id_or_slug.to_i
      title = $3

      tag = case name
      when 'image'
        if image = id > 0 ? Image.find_by_id(id) : Image.find_by_slug(id_or_slug)
          title = image.title if !title.nil? && title.empty?
          %Q[<img src="#{image.url}" alt="#{image.title}"/>]
        end
      else
        '%%% unknown %%%'
      end

      if title.blank?
        tag
      else
        %Q[<div class="#{name}">#{tag}<span class="title">#{title}</span></div>]
      end
    end
  end
end
