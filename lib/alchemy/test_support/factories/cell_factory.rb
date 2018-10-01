require 'factory_bot'
require 'alchemy/test_support/factories/page_factory'

FactoryBot.define do
  factory :alchemy_cell, class: 'Alchemy::Cell' do
    page { Alchemy::Page.find_by(language_root: true) || FactoryBot.create(:alchemy_page, :language_root) }
    name { "a_cell" }
  end
end
