require 'rails'

module Alchemy
  module Generators
    class ViewsGenerator < ::Rails::Generators::Base
      ALCHEMY_VIEWS = %w(breadcrumb language_links messages_mailer navigation)

      desc "Generates Alchemy views for #{ALCHEMY_VIEWS.to_sentence}."

      class_option :only,
        type: :array,
        default: nil,
        desc: "List of views to copy. Available views are #{ALCHEMY_VIEWS.to_sentence}."

      class_option :except,
        type: :array,
        default: nil,
        desc: "List of views not to copy. Available views are #{ALCHEMY_VIEWS.to_sentence}."

      source_root File.expand_path("../../../../../app/views/alchemy", __dir__)

      def copy_alchemy_views
        views_to_copy.each do |dir|
          directory dir, Rails.root.join('app/views/alchemy', dir)
        end
      end

      private

      def views_to_copy
        if @options['except']
          ALCHEMY_VIEWS - @options['except']
        elsif @options['only']
          ALCHEMY_VIEWS.select { |v| @options['only'].include?(v) }
        else
          ALCHEMY_VIEWS
        end
      end
    end
  end
end
