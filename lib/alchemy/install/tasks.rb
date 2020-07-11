# frozen_string_literal: true
require "thor"

module Alchemy
  module Install
    class Tasks < Thor
      include Thor::Actions

      no_tasks do
        def inject_routes
          mountpoint = ask "- At which path do you want to mount Alchemy CMS at? (DEFAULT: At root path '/')"
          mountpoint = "/" if mountpoint.empty?
          sentinel = /\.routes\.draw do(?:\s*\|map\|)?\s*$/
          inject_into_file "./config/routes.rb", "\n  mount Alchemy::Engine => '#{mountpoint}'\n", { after: sentinel, verbose: true }
        end

        def set_primary_language
          code = ask "- What is the language code of your site's primary language? (DEFAULT: en)"
          code = "en" if code.empty?
          name = ask "- What is the name of your site's primary language? (DEFAULT: English)"
          name = "English" if name.empty?
          gsub_file "./config/alchemy/config.yml", /default_language:\n\s\scode:\sen\n\s\sname:\sEnglish/m do
            "default_language:\n  code: #{code}\n  name: #{name}"
          end
        end

        def inject_seeder
          append_file "./db/seeds.rb", "Alchemy::Seeder.seed!\n"
        end
      end
    end
  end
end
