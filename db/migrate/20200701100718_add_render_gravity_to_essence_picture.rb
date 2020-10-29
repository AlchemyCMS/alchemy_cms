# frozen_string_literal: true

class AddRenderGravityToEssencePicture < ActiveRecord::Migration[5.2]
  def change
    add_column :alchemy_essence_pictures, :render_gravity, :string
  end
end
