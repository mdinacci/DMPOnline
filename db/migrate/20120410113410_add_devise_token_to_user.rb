class AddDeviseTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    add_column :users, :token_created_at, :datetime
  end
end
