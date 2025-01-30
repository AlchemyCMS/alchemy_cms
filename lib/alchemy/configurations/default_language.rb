# frozen_string_literal: true

module Alchemy
  module Configurations
    class DefaultLanguage < Alchemy::Configuration
      option :name, :string, default: "English"
      option :code, :string, default: "en"
      option :page_layout, :string, default: "index"
      option :frontpage_name, :string, default: "Index"
    end
  end
end
