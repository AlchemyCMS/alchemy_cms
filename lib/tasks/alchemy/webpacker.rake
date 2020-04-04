# frozen_string_literal: true

namespace :alchemy do
  namespace :yarn do
    desc "Install Alchemy JavaScript dependencies as specified via Yarn"
    task :install do
      Dir.chdir(File.join(__dir__, "../..")) do
        puts "🧙‍♂️ Install AlchemyCMS JS bundle"
        system "yarn install --no-progress --production"
      end
    end
  end

  namespace :webpacker do
    desc "Compile Alchemy JavaScript packs using webpack for production with digests"
    task compile: :environment do
      require "fileutils"
      Webpacker.with_node_env("production") do
        start = Time.now
        puts "🧙‍♂️ Compile AlchemyCMS JS packs"
        if Alchemy.webpacker.commands.compile
          FileUtils.cp_r(
            Alchemy::Engine.root.join("public", "alchemy-packs"),
            Rails.root.join("public")
          )
        else
          # Failed compilation
          exit!
        end
        puts "🧙‍♂️ Done in #{(Time.now - start).round(2)}s."
      end
    end
  end
end

# Compile packs after compiled all other assets during precompilation
Rake::Task["assets:precompile"].enhance do
  Rake::Task["alchemy:webpacker:compile"].invoke
end

Rake::Task["yarn:install"].enhance do
  Rake::Task["alchemy:yarn:install"].invoke
end
