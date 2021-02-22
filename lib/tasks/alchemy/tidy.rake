# frozen_string_literal: true
require "alchemy/tasks/tidy"

namespace :alchemy do
  namespace :tidy do
    desc "Tidy up Alchemy database."
    task :up do
      Rake::Task["alchemy:tidy:element_positions"].invoke
      Rake::Task["alchemy:tidy:content_positions"].invoke
      Rake::Task["alchemy:tidy:remove_orphaned_records"].invoke
      Rake::Task["alchemy:tidy:remove_trashed_elements"].invoke
      Rake::Task["alchemy:tidy:remove_duplicate_legacy_urls"].invoke
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
      Rake::Task["alchemy:tidy:remove_orphaned_elements"].invoke
      Rake::Task["alchemy:tidy:remove_orphaned_contents"].invoke
    end

    desc "Remove orphaned elements."
    task remove_orphaned_elements: [:environment] do
      Alchemy::Tidy.remove_orphaned_elements
    end

    desc "Remove orphaned contents."
    task remove_orphaned_contents: [:environment] do
      Alchemy::Tidy.remove_orphaned_contents
    end

    desc "Remove trashed elements."
    task remove_trashed_elements: [:environment] do
      Alchemy::Tidy.remove_trashed_elements
    end

    desc "Remove duplicate legacy URLs"
    task remove_duplicate_legacy_urls: [:environment] do
      Alchemy::Tidy.remove_duplicate_legacy_urls
    end

    desc "List Alchemy elements usage"
    task elements_usage: :environment do
      puts "\n"
      removable_elements = []
      names = Alchemy::Element.definitions.map { |e| e["name"] }
      longest_name = names.max_by { |name| name.to_s.length }.length + 1
      names.sort.each do |name|
        names = Alchemy::Element.where(name: name)
        count = names.count
        page_count = Alchemy::Page.where(id: names.pluck(:page_id)).published.count
        if count.zero?
          removable_elements.push(name)
        else
          spacer = " " * (longest_name - name.length)
          puts "#{name}#{spacer}is used\t#{count}\ttime(s) on\t#{page_count}\tpublic page(s)"
        end
      end
      if removable_elements.many?
        puts "\n"
        puts "These elements can probably be removed. They are not used anywhere:"
        puts "\n"
        removable_elements.each do |name|
          puts name
        end
      end
    end
  end
end
