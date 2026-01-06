# frozen_string_literal: true

require 'rails'
require 'alchemy/i18n'

module AlchemyI18n
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Installs Alchemy locales into your App."

      def self.description
        locales = Alchemy::I18n.available_locales.to_sentence
        "Available locales are #{locales}"
      end

      class_option :locales,
        type: :array,
        default: [],
        desc: "Locales to generate files for. #{description}"

      source_root AlchemyI18n::Engine.root

      def add_rails_i18n
        environment do
          "config.i18n.available_locales = #{locales.inspect}"
        end
      end

      def add_russian_gem
        if locales.include?('ru')
          gem 'russian', '~> 0.6'
        end
      end

      private

      def locales
        @_locales ||= begin
          options[:locales].presence || ask_locales.split(" ")
        end.map(&:to_sym)
      end

      def ask_locales
        ask <<~LOCALES
          Which locales should we generate files for?
          #{self.class.description}
          (separate multiple locales with space):
        LOCALES
      end
    end
  end
end
