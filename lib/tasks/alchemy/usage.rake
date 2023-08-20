require "alchemy/tasks/usage"

namespace :alchemy do
  desc "List Alchemy elements and pages usage"
  task usage: [:page_usage, :element_usage]

  desc "List Alchemy elements usage"
  task page_usage: :environment do
    include ActionView::Helpers::NumberHelper
    puts "\n  Alchemy pages usage"
    results = Alchemy::Tasks::Usage.pages_count_by_type
    if results.any?
      puts "  ----------------------"
      puts "\n"
      results.each do |row|
        puts "  #{number_with_delimiter(row["count"])} 𝗑 #{row["page_layout"]}"
      end
      puts "\n  = #{number_with_delimiter(Alchemy::Page.count)} pages in total."
    else
      puts "  > No pages found!"
    end
  end

  desc "List Alchemy elements usage"
  task element_usage: :environment do
    include ActionView::Helpers::NumberHelper
    puts "\n  Alchemy elements usage"
    results = Alchemy::Tasks::Usage.elements_count_by_name
    if results.any?
      puts "  ----------------------"
      puts "\n"
      results.each do |row|
        ingredients = row.key?("ingredients") ? "uses ingredients ✅" : nil
        contents = row.key?("contents") ? "still uses contents ‼️" : nil
        type = ingredients || contents
        suffix = type ? " · #{type}" : nil
        puts "  #{number_with_delimiter(row["count"])} 𝗑 #{row["name"]}#{suffix}"
      end
      puts "\n  = #{number_with_delimiter(Alchemy::Element.count)} elements in total."
    else
      puts "  > No elements found!"
    end
  end
end
