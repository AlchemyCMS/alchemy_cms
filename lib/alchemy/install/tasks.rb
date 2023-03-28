# frozen_string_literal: true
require "thor"

module Alchemy
  module Install
    class Tasks < Thor
      include Thor::Actions

      no_tasks do
        def inject_routes(auto_accept = false)
          return if File.read("./config/routes.rb").match?("mount Alchemy::Engine")

          mountpoint = "/"
          unless auto_accept
            mountpoint = ask("- At which path do you want to mount Alchemy CMS at?", default: mountpoint)
          end
          sentinel = /\.routes\.draw do(?:\s*\|map\|)?\s*$/
          inject_into_file "./config/routes.rb", "\n  mount Alchemy::Engine => '#{mountpoint}'\n", { after: sentinel, verbose: true }
        end

        def set_primary_language(code: "en", name: "English", auto_accept: false)
          unless auto_accept
            code = ask("- What is the language code of your site's primary language?", default: code)
          end
          unless auto_accept
            name = ask("- What is the name of your site's primary language?", default: name)
          end
          gsub_file "./config/alchemy/config.yml", /default_language:\n\s\scode:\sen\n\s\sname:\sEnglish/m do
            "default_language:\n  code: #{code}\n  name: #{name}"
          end
        end

        def inject_seeder
          seed_file = Rails.root.join("db", "seeds.rb")
          args = [seed_file, "Alchemy::Seeder.seed!\n"]
          if File.exist?(seed_file)
            append_file(*args)
          else
            add_file(*args)
          end
        end
      end
    end
  end
end
