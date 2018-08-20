# frozen_string_literal: true

require 'alchemy/test_support/factories'

Alchemy::Seeder.seed!

lang_root = FactoryBot.create(:alchemy_page, :language_root)
page_levels = ENV.fetch('PAGE_LEVELS', 10).to_i
pages_per_level = ENV.fetch('PAGES_PER_LEVEL', 100).to_i
parent_ids = []
parent_id = lang_root.id

puts "\nCreating #{page_levels * pages_per_level} Alchemy pages. Hold tight, this may take a while!\n"

page_levels.times do
  pages_per_level.times do
    page = FactoryBot.create(:alchemy_page, :public, parent_id: parent_id)
    parent_ids << page.id
    print "."
  end
  parent_id = parent_ids.sample
end

puts "\nDone!"
