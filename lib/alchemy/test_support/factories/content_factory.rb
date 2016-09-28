require 'factory_girl'
require 'alchemy/test_support/factories/essence_text_factory'

FactoryGirl.define do
  factory :alchemy_content, class: 'Alchemy::Content' do
    name "text"
    essence_type "Alchemy::EssenceText"
    association :essence, factory: :alchemy_essence_text
    association :element, factory: :alchemy_element
  end
end
