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
    text.gsub /\[(#{in_brackets}+?):(#{in_brackets}+?)\](?:\{(#{in_braces}*?)\})?/im do |ctag|
      command = $1
      id_or_slug = $2
      title = $3


      name, *classes = command.split('.').map(&:strip)
      classes ||= []
      wrap = !classes.empty?
      
      id = id_or_slug.to_i

      tag = case name
      when 'image'
        if image = Image.find_by_id(id) || Image.find_by_slug(id_or_slug)
          if !title.nil? && title.empty?
            title = image.title 
            wrap = true
          end
          %Q[<img src="#{image.url}" alt="#{image.title}"/>]
        else
          %Q[<div class="warning">Image not found: '#{id_or_slug}'</div>]
        end
      else
        '%%% unknown %%%'
      end

      title_tag = if title.blank?
        title
      else
        wrap = true
        %Q[<span class="title">#{title}</span>]
      end

      unless wrap
        tag
      else
        classes << name
        %Q[<div class="#{classes.uniq.join(' ')}">#{tag}#{title_tag}</div>]
      end
    end
  end
end
