module Alchemy::Upgrader::Tasks
  class InstallAssetManifests < Thor
    include Thor::Actions

    source_root File.expand_path('../../../rails/generators/alchemy/install/files',
      File.dirname(__FILE__))

    no_tasks do
      def install
        copy_file "all.js", "vendor/assets/javascripts/alchemy/admin/all.js"
        copy_file "all.css", "vendor/assets/stylesheets/alchemy/admin/all.css"
      end
    end
  end
end
