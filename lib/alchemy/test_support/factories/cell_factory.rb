require 'factory_girl'
require 'alchemy/test_support/factories/page_factory'

FactoryGirl.define do

  factory :alchemy_cell, class: 'Alchemy::Cell' do
    page { Alchemy::Page.find_by(language_root: true) || FactoryGirl.create(:alchemy_page, :language_root) }
    name "a_cell"
  end
end
