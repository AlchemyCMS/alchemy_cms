require 'factory_girl'

FactoryGirl.define do

  factory :alchemy_attachment, class: 'Alchemy::Attachment' do
    file File.new(File.expand_path('../../../../../spec/fixtures/image.png', __FILE__))
    name 'image'
    file_name 'image.png'
  end
end
