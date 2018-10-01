require 'factory_bot'

FactoryBot.define do
  factory :alchemy_essence_text, class: 'Alchemy::EssenceText' do
    body { 'This is a headline' }
  end
end
