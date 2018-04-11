# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe EssenceRichtext do
    let(:essence) do
      EssenceRichtext.new(body: '<h1>Hello!</h1><p>Welcome to Peters Petshop.</p>')
    end

    it_behaves_like "an essence" do
      let(:essence) { EssenceRichtext.new }
      let(:ingredient_value) { '<h1>Hello!</h1><p>Welcome to Peters Petshop.</p>' }
    end

    it "should save a HTML tag free version of body column" do
      essence.save
      expect(essence.stripped_body).to eq("Hello!Welcome to Peters Petshop.")
    end

    it 'has tinymce enabled' do
      expect(essence.has_tinymce?).to eq(true)
    end
  end
end
