module Alchemy::Language::Code
  extend ActiveSupport::Concern

  def code
    [language_code, country_code].select(&:present?).join('-')
  end

  def code=(code)
    self.language_code = code
  end

  module ClassMethods

    def find_by_code(code)
      codes = code.split('-')
      codes << '' if codes.length == 1
      find_by_language_code_and_country_code *codes
    end

  end

end
