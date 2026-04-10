class AddTimezoneToAlchemyUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :alchemy_users, :timezone, :string, if_not_exists: true,
      comment: "The timezone of the user, used for displaying dates in the user's timezone"
  end
end
