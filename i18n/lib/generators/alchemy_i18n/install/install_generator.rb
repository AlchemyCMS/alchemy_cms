# frozen_string_literal: true

require 'rails'
require 'alchemy/i18n'

module AlchemyI18n
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Installs Alchemy locales into your App."

      def self.description
        locales = Alchemy::I18n.available_locales.reject { |l| l == :en }.to_sentence
        "Available locales are #{locales}"
      end

      class_option :locales,
        type: :array,
        default: [],
        desc: "Locales to generate files for. #{description}"

      source_root AlchemyI18n::Engine.root

      def append_assets
        locales.each do |locale|
          append_file 'vendor/assets/javascripts/alchemy/admin/all.js', <<~ASSETS
            //= require alchemy_i18n/#{locale}
            //= require select2_locale_#{locale}
            //= require flatpickr/#{locale}
          ASSETS
        end
      end

      def append_manifest
        locales.each do |locale|
          append_file 'app/assets/config/manifest.js', <<~MANIFEST
            //= link tinymce/langs/#{locale}.js
          MANIFEST
        end
      end

      def add_rails_i18n
        environment do
          "config.i18n.available_locales = #{locales.map(&:to_sym).inspect}"
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
          options[:locales].presence || ask_locales.split(' ')
        end
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
