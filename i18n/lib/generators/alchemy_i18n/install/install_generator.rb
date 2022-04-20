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

      def append_assets
        additional_locales.each do |locale|
          append_file 'vendor/assets/javascripts/alchemy/admin/all.js', <<~ASSETS
            //= require alchemy_i18n/#{locale}
            //= require select2_locale_#{locale}
          ASSETS
        end
      end

      def append_manifest
        additional_locales.each do |locale|
          append_file 'app/assets/config/manifest.js', <<~MANIFEST
            //= link tinymce/langs/#{locale}.js
          MANIFEST
        end
      end

      def append_pack
        webpack_config = YAML.load_file(Rails.root.join("config", "webpacker.yml"))[Rails.env]
        pack = Rails.root.join(webpack_config["source_path"], webpack_config["source_entry_path"], "alchemy/admin.js")
        additional_locales.each do |locale|
          append_file pack, <<~PACK
            import "flatpickr/dist/l10n/#{locale}.js"
          PACK
        end
      end

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

      def additional_locales
        @_additional_locales ||= locales.reject { |locale| locale == :en }
      end

      def locales
        @_locales ||= begin
          options[:locales].presence || ask_locales.split(" ")
        end.map(&:to_sym)
      end

      def ask_locales
        ask <<~LOCALES
          Which locales should we generate files for?
          #{self.class.description}
          (seperate multiple locales with space):
        LOCALES
      end
    end
  end
end
