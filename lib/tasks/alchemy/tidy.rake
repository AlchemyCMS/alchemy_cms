require 'alchemy/tasks/tidy'

namespace :alchemy do
  namespace :tidy do
    desc "Tidy up Alchemy database."
    task :up do
      Rake::Task['alchemy:tidy:element_positions'].invoke
      Rake::Task['alchemy:tidy:content_positions'].invoke
      Rake::Task['alchemy:tidy:remove_orphaned_records'].invoke
    end

    desc "Fixes element positions."
    task element_positions: [:environment] do
      Alchemy::Tidy.update_element_positions
    end

    desc "Fixes content positions."
    task content_positions: [:environment] do
      Alchemy::Tidy.update_content_positions
    end

    desc "Remove orphaned records (elements & contents)."
    task remove_orphaned_records: [:environment] do
      Rake::Task['alchemy:tidy:remove_orphaned_elements'].invoke
      Rake::Task['alchemy:tidy:remove_orphaned_contents'].invoke
    end

    desc "Remove orphaned elements."
    task remove_orphaned_elements: [:environment] do
      Alchemy::Tidy.remove_orphaned_elements
    end

    desc "Remove orphaned contents."
    task remove_orphaned_contents: [:environment] do
      Alchemy::Tidy.remove_orphaned_contents
    end
  end
end
