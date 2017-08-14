# frozen_string_literal: true

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
      on_current_site.find_by(
        language_code: codes[0],
        country_code: codes[1]
      )
    end
  end
end
