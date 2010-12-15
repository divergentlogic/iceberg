require 'stringex'

module LuckySneaks
  module StringExtensions
    alias_method :convert_misc_characters_without_plus, :convert_misc_characters
    def convert_misc_characters_with_plus
      convert_misc_characters_without_plus.dup.gsub(/\+/, " plus ")
    end
    alias_method :convert_misc_characters, :convert_misc_characters_with_plus
  end
end
