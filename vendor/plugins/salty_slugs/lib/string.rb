module Norbauer
  module SaltySlugs
    module String
      def sluggify
        if defined?(Unicode)
          str = Unicode.normalize_KD(self).gsub(/[^\x00-\x7F]/n,'')
          str = str.gsub(/\W+/, '-').gsub(/^-+/,'').gsub(/-+$/,'').downcase
          return str
        else
          str = Iconv.iconv('ascii//translit', 'utf-8', self).to_s
          str.gsub!(/\W+/, ' ')
          str.strip!
          str.downcase!
          str.gsub!(/\ +/, '-')
          return str
        end
      end
    end
  end
end

