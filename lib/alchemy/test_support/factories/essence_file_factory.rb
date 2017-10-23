require 'factory_bot'
require 'alchemy/test_support/factories/attachment_factory'

FactoryBot.define do
  factory :alchemy_essence_file, class: 'Alchemy::EssenceFile' do
    attachment factory: :alchemy_attachment
  end
end
