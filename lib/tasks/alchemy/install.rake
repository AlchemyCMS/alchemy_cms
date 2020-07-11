# frozen_string_literal: true

namespace :alchemy do
  desc "Installs Alchemy CMS into your app."
  task :install do
    require "generators/alchemy/install/install_generator"
    Alchemy::Generators::InstallGenerator.start
  end

  desc "Mounts Alchemy into your routes."
  task :mount do
    require "alchemy/install/tasks"
    Alchemy::InstallTasks.new.inject_routes
  end
end
