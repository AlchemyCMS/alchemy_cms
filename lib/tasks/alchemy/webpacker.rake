# frozen_string_literal: true

namespace :alchemy do
  namespace :webpacker do
    desc "Install Alchemy JS dependencies with yarn"
    task :yarn_install do
      puts "\nInstalling AlchemyCMS' JS dependencies..."
      Dir.chdir(File.join(__dir__, "../..")) do
        system "yarn install --no-progress --production"
      end
    end

    desc "Compile Alchemy JS packs for production into the host app."
    task compile: [:yarn_install, :environment] do
      Webpacker.with_node_env(ENV['NODE_ENV'] || 'production') do
        puts "\nCompiling AlchemyCMS' JS packs..."

        output_path = Webpacker.config.public_path.join('alchemy-packs')
        stdout, stderr, status = Open3.capture3(
          Alchemy.webpacker.compiler.send(:webpack_env),
          "#{RbConfig.ruby} ./bin/webpack --output-path=#{output_path}",
          chdir: Alchemy::Engine.root
        )
        if status.success?
          $stdout.puts(stdout)
          puts "\n✅ Successfully compiled AlchemyCMS' JS packs"
        else
          $stderr.puts(stderr)
          puts "\n❌ Failed compiling AlchemyCMS' JS packs"
        end
      end
    end
  end
end

# Compile Alchemy packs with Host apps assets
Rake::Task["assets:precompile"].enhance do
  Rake::Task["alchemy:webpacker:compile"].invoke
end
